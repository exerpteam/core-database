-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                         AS center
        , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , $$from_date$$::DATE                                             AS from_date
        , $$to_date$$::DATE                                             AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
SELECT
    c.name                                                     AS "Club"
    ,il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID           AS "Invoice Line ID"
    ,il.CENTER || 'inv' || il.ID                               AS "Invoice ID"
    ,p.external_id                                             AS "Member Number"
    , COALESCE(opp.external_id, mfp.external_id,p.external_id) AS "Primary Member Number"
    , pr.name                                                  AS "Sales Item Name"
    ,pr.globalid                                               AS "Sales Item Code"
    ,pr.external_id                                            AS "Sales Item Analysis Code"
    ,longtodatec(inv.entry_time,il.center )                    AS "Sales Item Purchase Date"
    ,il.total_amount                                           AS "Sales Item Price"
    , il.quantity                                              AS "Quantity"
    ,inv.employee_center||'emp'||inv.employee_id               AS "Sale Employee ID"
    ,staff.fullname                                            AS "Sale Employee Name"
    ,er.id is not null as "API User"
FROM
    persons p
JOIN
    invoice_lines_mt il
ON
    il.person_center = p.center
AND il.person_id = p.id
JOIN
    invoices inv
ON
    inv.center = il.center
AND inv.id = il.id
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    persons opp
ON
    op.center = opp.center
AND op.id = opp.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id = p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    persons mfp
ON
    mf.relativecenter =mfp.center
AND mf.relativeid =mfp.id
JOIN
    centers c
ON
    c.id = il.center
JOIN
    products pr
ON
    il.productcenter = pr.center
AND il.productid = pr.id
LEFT JOIN
    employees emp
ON
    emp.center = inv.employee_center
AND emp.id = inv.employee_id
LEFT JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
JOIN
    params
ON
    params.center = il.center
LEFT JOIN 
    employeesroles er 
ON 
    er.center = emp.center 
AND er.id = emp.id 
AND er.roleid = 179 -- UseAPI
WHERE
    il.center IN ($$scope$$)
AND inv.entry_time BETWEEN params.from_date_long AND params.to_date_long
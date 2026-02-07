-- adjustments can be subscription price changes or payment account adjustments
-- applied should only include subscription price
--created should include both subscription price and account transactions
-- exclude free credit notes
WITH
    params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                     AS center,
            datetolongc($$from_date$$::DATE::VARCHAR,c.id) AS from_date_long ,
            datetolongc($$to_date$$::DATE::VARCHAR,c.id) AS to_date_long,
            $$from_date$$::DATE                            AS from_date,
            $$to_date$$::DATE                            AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
    ,
    MCP_end_dates AS
    (
        SELECT
            owner_center            AS center ,
            owner_id                AS id,
            MAX(s.binding_end_date) AS binding_end_date
        FROM
            evolutionwellness.subscriptions s
        JOIN
            evolutionwellness.products pr
        ON
            pr.center = s.subscriptiontype_center
        AND pr.id = s.subscriptiontype_id
        LEFT JOIN
            evolutionwellness.product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        AND ppgl.product_group_id = 111
        WHERE
            s.state IN (2,4)
        AND ppgl.product_group_id IS NULL
        GROUP BY
            owner_center ,
            owner_id
    )
SELECT
    c.name        AS "Club",
    c.id          AS "Club Number",
    c.external_id AS "Club Code",
    p.external_id AS "Member Number",
    NULL          AS "Join Date",
    -- what is MCP End Date? is it the subscription end date?
    s.end_date AS "MCP End Date",
    -- how to handle staff with corporate relations? e.g. person 2212 352p206
    r.center IS NOT NULL AS "Is Corporate",
    corp.fullname        AS "Corporate Name",
    sp.from_date         AS "Date",
    staff.fullname       AS "Operator",
    CASE
        WHEN pp.price_modification_name = 'FIXED_REBATE'
        THEN pp.price_modification_amount::VARCHAR
        WHEN pp.price_modification_name = 'FREE'
        THEN pp.price_modification_name
        WHEN pp.price_modification_amount IS NULL
        THEN sp.price::VARCHAR
        ELSE pp.price_modification_name
    END     AS "Adjustment Amount",
    sp.type AS "Adjustment Type",
    -- I am not sure what to put in the adjustment reason when reporting on subscription price
    -- changes
    NULL         AS "Adjustment Reason",
    sp.coment    AS "Notes",
    sp.from_date AS "Adjustment Start Date",
    sp.to_date   AS "Adjustment End Date"
FROM
    evolutionwellness.subscription_price sp
JOIN
    evolutionwellness.centers c
ON
    c.id = sp.subscription_center
JOIN
    params
ON
    params.center = c.id
JOIN
    evolutionwellness.subscriptions s
ON
    s.center = sp.subscription_center
AND s.id = sp.subscription_id
JOIN
    evolutionwellness.persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN
    evolutionwellness.relatives r
ON
    r.relativecenter = p.center
AND r.relativeid = p.id
AND r.rtype = 2
AND r.status < 2
LEFT JOIN
    evolutionwellness.persons corp
ON
    corp.center = r.center
AND corp.id = r.id
JOIN
    evolutionwellness.employees emp
ON
    emp.center = sp.employee_center
AND emp.id = sp.employee_id
JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
LEFT JOIN
    evolutionwellness.privilege_usages pu
ON
    pu.target_service = 'SubscriptionPrice'
AND pu.target_id = sp.id
LEFT JOIN
    evolutionwellness.product_privileges pp
ON
    pp.id = pu.privilege_id
WHERE
    p.external_id IS NOT NULL
AND (
        sp.type = 'INDIVIDUAL'
    OR  (
            pp.id IS NOT NULL
        AND pp.price_modification_name != 'NONE'))
AND sp.entry_time BETWEEN params.from_date_long AND params.to_date_long
UNION ALL
SELECT
    c.name               AS "Club",
    c.id                 AS "Club Number",
    c.external_id        AS "Club Code",
    p.external_id        AS "Member Number",
    NULL                 AS "Join Date",
    mcp.binding_end_date AS "MCP End Date",--Binding end date
    -- how to handle staff with corporate relations? e.g. person 2212 352p206
    r.center IS NOT NULL                    AS "Is Corporate",
    corp.fullname                           AS "Corporate Name",
    longtodateC(art.entry_time, art.center) AS "Date",
    staff.fullname                          AS "Operator",
    art.amount::VARCHAR                     AS "Adjustment Amount",
    -- not sure what to put in the Adjustment type here
    'AR Transaction' AS "Adjustment Type",
    -- I am not sure what to put in the adjustment reason when reporting on subscription price
    -- changes
    NULL                                    AS "Adjustment Reason",
    art.text                                AS "Notes",
    longtodateC(art.entry_time, art.center) AS "Adjustment Start Date",
    longtodateC(art.entry_time, art.center) AS "Adjustment End Date"
FROM
    evolutionwellness.ar_trans art
JOIN
    evolutionwellness.centers c
ON
    c.id = art.center
JOIN
    params
ON
    params.center = c.id
JOIN
    evolutionwellness.account_receivables ar
ON
    ar.center = art.center
AND ar.id= art.id
JOIN
    evolutionwellness.persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
LEFT JOIN
    MCP_end_dates mcp
ON
    mcp.center = p.center
AND mcp.id = p.id
LEFT JOIN
    evolutionwellness.relatives r
ON
    r.relativecenter = p.center
AND r.relativeid = p.id
AND r.rtype = 2
AND r.status < 2
LEFT JOIN
    evolutionwellness.persons corp
ON
    corp.center = r.center
AND corp.id = r.id
JOIN
    evolutionwellness.employees emp
ON
    emp.center = art.employeecenter
AND emp.id = art.employeeid
JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
WHERE
    p.external_id IS NOT NULL
AND art.entry_time BETWEEN params.from_date_long AND params.to_date_long
    -- what types or AR trans are the manual adjustments? I need an example to verify that the list
    -- is correct
AND art.ref_type = 'CREDIT_NOTE'
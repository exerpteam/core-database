-- The extract is extracted from Exerp on 2026-02-08
-- Use IT audit 
WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:from_date), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS from_date,
            CAST(datetolongC(TO_CHAR(TO_DATE((:to_date), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS to_date,
            c.id    AS centerid
        FROM
            centers c
    )
    SELECT
    TO_CHAR(longtodate(t.entry_time), 'dd-MM-YY HH24:MI'),
    t.change_type,
    t.type,
    CASE
       /* WHEN t.type = 'eventConfiguration'
        THEN etc.event_source_service */
        WHEN t.type = 'extractQuery'
        THEN ex.name
        WHEN t.type = 'paymentCycleConfig'
        THEN pcc.name
        /*WHEN t.type = 'template'
        THEN te.description */
        ELSE t.source_prime
    END AS property,
    --t.source_prime,
    --t.source_second,
    t.employee_id
    FROM
    (
SELECT
    cl.entry_time,
    CASE cl.type
        WHEN 1
        THEN 'Add'
        WHEN 2
        THEN 'Update'
        WHEN 3
        THEN 'Remove'
    END             AS change_type,
    cl.service_name AS Type,
    cl.source_primary AS source_prime,
    cl.source_secondary AS source_second,
    CASE cl.service_name
    /*WHEN 'eventConfiguration'
    THEN CAST(cl.source_primary AS INT) */
    WHEN 'extractQuery'
    THEN CAST(cl.source_primary AS INT)
    WHEN 'paymentCycleConfig'
    THEN CAST(cl.source_primary AS INT)
    /*WHEN 'template'
    THEN CAST(cl.source_primary AS INT) */
    END AS source_primary,
    cl.employee_center ||'emp'|| cl.employee_id AS employee_id
FROM
    change_logs cl
JOIN
    params par
ON
    par.centerid = cl.employee_center
WHERE
    cl.entry_time BETWEEN par.from_date AND par.to_date
AND EXISTS
    (
        SELECT
            1
        FROM
            persons p
        JOIN
            employees emp
        ON
            emp.personcenter = p.center
        AND emp.personid = p.id
        JOIN
            employeesroles empr
        ON
            empr.center = emp.center
        AND empr.id = emp.id
        LEFT JOIN
            roles r
        ON
            r.id = empr.roleid
        AND r.blocked = false
        LEFT JOIN
            impliedemployeeroles iempr
        ON
            iempr.roleid = r.id
        LEFT JOIN
            roles roac
        ON
            roac.id = iempr.implied
        WHERE
            (
                r.id IN (211,
                         6490,
                         55,
                         448,
                         34,
                         3)
            OR  roac.id IN (211,
                            6490,
                            55,
                            448,
                            34,
                            3))
		AND emp.last_login >= '2023-01-01'
        AND p.fullname NOT LIKE 'Exerp Support%'
        AND p.fullname NOT LIKE 'EXERP SUPPORT%'
        AND p.fullname NOT LIKE 'EXERP STAFF%'
        AND p.persontype = 2
        AND emp.center = cl.employee_center
        AND emp.id = cl.employee_id) ) t
/*        LEFT JOIN
    templates te
ON
    te.ttype = t.source_primary
AND t.type = 'template'
AND t.source_second = te.scope_type||te.scope_id */
LEFT JOIN
    payment_cycle_config pcc
ON
    pcc.id = t.source_primary
AND t.type = 'paymentCycleConfig'
LEFT JOIN
    extract ex
ON
    ex.id = t.source_primary
AND t.type = 'extractQuery'
/*LEFT JOIN
    event_type_config etc
ON
    etc.event_type_id = t.source_primary
AND t.type = 'eventConfiguration' 
AND t.source_second = etc.scope_type||etc.scope_id */
ORDER BY
t.entry_time
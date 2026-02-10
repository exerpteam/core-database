-- The extract is extracted from Exerp on 2026-02-08
-- All members in debt who do NOT have a open task in CRM
WITH
    params AS MATERIALIZED
    (   SELECT
            TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS cutDate,
            c.id                                      AS centerid,
            c.name
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
SELECT
    p.fullname            AS "Full name",
    p.external_id         AS " Member ID",
    p.center ||'p'|| p.id AS "Person ID",
    SUM(art.amount)       AS "Debt amount",
    par.name              AS "Center"
FROM
    persons p
JOIN
    params par
ON
    par.centerId = p.center
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
AND art.amount < 0
AND art.status NOT IN ('CLOSED')
AND (art.due_date < par.cutDate OR (art.due_date IS NULL AND art.text = 'Legacy Debt'))
WHERE
    p.sex != 'C'
AND p.status NOT IN (4,5,7,8)
AND ar.balance < 0
AND NOT EXISTS
    (   SELECT
            1
        FROM
            tasks ta
        WHERE
            ta.status IN ('OPEN',
                          'UNASSIGNED',
                          'OVERDUE')
        AND ta.person_center = p.center
        AND ta.person_id = p.id)
GROUP BY
    p.fullname,
    p.external_id,
    p.center ||'p'|| p.id,
    par.name
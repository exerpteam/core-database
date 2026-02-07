-- This is the version from 2026-02-05
-- All members in debt and whether they have an open task in cRM or not.
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
    p.fullname                 AS "Full name",
    p.external_id              AS "Member ID",
    p.center ||'p'|| p.id      AS "Person ID",
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
    SUM(art.amount)            AS "Debt amount",
    par.name                   AS "Center",
    sub.center ||'ss'|| sub.id AS "Subscription ID",
    sub.name                   AS "Subscription name",
    CASE
        WHEN EXISTS
            (   SELECT
                    1
                FROM
                    tasks ta
                WHERE
                    ta.status IN ('OPEN',
                                  'UNASSIGNED',
                                  'OVERDUE')
                AND ta.person_center = p.center
                AND ta.person_id = p.id )
        THEN 'YES'
        ELSE 'NO'
    END AS "Has Open Task",
    case when p.sex = 'C' then 'Yes' else 'No' end as Organization,
    DATE_PART('day', NOW() - TO_TIMESTAMP(MIN(art.entry_time) / 1000))::int AS "Days since debt"
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
AND
    (
        art.due_date < par.cutDate
    OR
        (
            art.due_date IS NULL
        AND art.text = 'Legacy Debt'))
LEFT JOIN
    ( 
    SELECT
            distinct on (s.owner_center, s.owner_id)
            s.owner_center,
            s.owner_id,
            s.center,
            s.id,
            pr.name
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        order by s.owner_center, s.owner_id, s.end_date desc) sub
ON
    sub.owner_center = p.center
AND sub.owner_id = p.id
WHERE
p.status NOT IN (7,8)
--AND ar.balance < 0
GROUP BY
    p.fullname,
    p.external_id,
    p.center,
    p.id,
    p.sex,
p.status,
    par.name,
    sub.center,
    sub.id,
    sub.name,
    CASE
        WHEN EXISTS
            (   SELECT
                    1
                FROM
                    tasks ta
                WHERE
                    ta.status IN ('OPEN',
                                  'UNASSIGNED',
                                  'OVERDUE')
                AND ta.person_center = p.center
                AND ta.person_id = p.id )
        THEN 'YES'
        ELSE 'NO'
    END;
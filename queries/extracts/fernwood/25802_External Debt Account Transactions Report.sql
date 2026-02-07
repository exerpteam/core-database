WITH params AS (
    SELECT
        datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS center_id,
        CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
SELECT
    longtodateC(art.entry_time, art.center) AS "Date",
    art.text AS "Text",
    CASE
        WHEN art.amount > 0 THEN art.amount
        ELSE art.amount
    END AS "Amount",
    c.shortname AS "Center",
    art.info AS "Info",
    ar.customercenter || 'p' || ar.customerid AS "Person ID",
    p.fullname AS "Full Name"
FROM
    fernwood.ar_trans art
JOIN
    fernwood.account_receivables ar
    ON ar.center = art.center AND ar.id = art.id
JOIN
    fernwood.persons p
    ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN
    fernwood.centers c
    ON c.id = art.center
JOIN
    params pms
    ON pms.center_id = art.center
WHERE
    ar.ar_type = 5 -- External Debt account
    AND art.entry_time BETWEEN pms.FromDate AND pms.ToDate
    AND art.center IN (:Scope)
ORDER BY
    art.entry_time DESC;

WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromdate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT)+86400000-1 AS todate,
            c.id               AS centerid
        FROM
            centers c
    )
SELECT
    --com.center ||'p'|| com.id AS companykey,
    --com.fullname              AS company_name,
    --p.center ||'p'|| p.id     AS personkey,
    p.fullname                AS person_name,
    p.ssn,
    p.birthdate,
    --longtodate(scl.entry_start_time) AS entry_time,
    t1.start_date AS subscription_start,
    t1.price,
    arca.balance+arpa.balance AS credits
FROM
    persons com
JOIN
    params par
ON
    par.centerid = com.center
JOIN
    relatives r
ON
    r.center = com.center
AND r.id = com.id
AND r.rtype = 2
JOIN
    state_change_log scl
ON
    scl.center = r.center
AND scl.id = r.id
AND scl.subid = r.subid
AND scl.stateid < 2
JOIN
    persons p
ON
    p.center = r.relativecenter
AND p.id = r.relativeid
LEFT JOIN
(SELECT
s.owner_center,
s.owner_id,
s.start_date,
sp.price
FROM
subscriptions s
JOIN
subscription_price sp
ON
sp.subscription_center = s.center
AND sp.subscription_id = s.id
WHERE
s.start_date BETWEEN :fromdate AND :todate
AND sp.from_date BETWEEN :fromdate AND :todate
AND sp.cancelled = false
AND s.start_date = sp.from_date
) t1
ON
t1.owner_center = p.center
AND t1.owner_id = p.id
LEFT JOIN
account_receivables arpa
ON
arpa.customercenter = p.center
AND arpa.customerid = p.id
AND arpa.ar_type = 4
AND arpa.balance > 0
LEFT JOIN
account_receivables arca
ON
arca.customercenter = p.center
AND arca.customerid = p.id
AND arca.ar_type = 1
AND arca.balance > 0
WHERE
    scl.entry_start_time BETWEEN par.fromdate AND par.todate
    AND (com.center ||'p'|| com.id) IN (:company)
ORDER BY
p.fullname
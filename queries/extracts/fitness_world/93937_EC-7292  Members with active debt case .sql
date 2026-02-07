-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
                                                                                        AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS
                    todate,
            c.id AS centerid
        FROM
            centers c
    )
SELECT DISTINCT
t.*
FROM
(
SELECT
    p.center ||'p'|| p.id                        AS memberid,
    p.external_id                                AS externalId,
    TO_CHAR((cc.currentstep_date), 'dd-MM-YYYY') AS DATE,
    cc.currentstep                               AS step
FROM
    persons p
JOIN
    cashcollectioncases cc
ON
    cc.personcenter = p.center
AND cc.personid = p.id
AND p.sex != 'C'
WHERE
    --cc.startdate >= '2023-06-01'
    cc.missingpayment = true
AND cc.closed = false
AND cc.currentstep_type = 1
AND cc.currentstep_date BETWEEN :fromdate AND :todate
UNION ALL
SELECT
    p.center ||'p'|| p.id                                AS memberid,
    p.external_id                                        AS externalId,
    TO_CHAR(longtodate(ccje.creationtime), 'dd-MM-YYYY') AS DATE,
    ccje.step                                            AS step
FROM
    cashcollectionjournalentries ccje
JOIN
    params
ON
    params.centerid = ccje.center
JOIN
    fw.cashcollectioncases cc
ON
    cc.center = ccje.center
AND cc.id = ccje.id
AND cc.missingpayment = true
AND cc.closed = false
JOIN
    persons p
ON
    p.center = cc.personcenter
AND p.id = cc.personid
AND p.sex != 'C'
WHERE
    ccje.step IN (2,3,5)
AND ccje.creationtime BETWEEN params.fromdate AND params.todate) t
ORDER BY
t.memberid,
t.step
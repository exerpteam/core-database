-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
                                                                                        AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS
                    todate,
            c.id AS centerid
        FROM
            centers c
    )

SELECT
    p.center ||'p'|| p.id                        AS memberid,
    p.external_id                                AS externalId,
    ccje.step AS step,
TO_CHAR(longtodateC(ccje.creationtime,params.centerid), 'YYYY-MM-dd') AS "date"
FROM
    cashcollectionjournalentries ccje
JOIN
    fw.cashcollectioncases cc
ON
    cc.center = ccje.center
AND cc.id = ccje.id
JOIN
    persons p
ON
    p.center = cc.personcenter
AND p.id = cc.personid
JOIN
    params
ON
    params.centerid = ccje.center
WHERE
    ccje.step IN (6)
AND p.sex != 'C'
AND ccje.creationtime BETWEEN params.fromdate AND params.todate
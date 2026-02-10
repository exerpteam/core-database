-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CASE
                WHEN $$offset$$=0
                THEN 0
                ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
            END                                                                           AS FROMDATE,
            CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS TODATE
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT
            ss.subscription_center||'ss'||ss.subscription_id AS "SUBSCRIPTION_ID",
            
            MAX(longtodateC(sig.creation_time,ss.subscription_center)) AS "SIGNATURE_TIMESTAMP",
            MAX(GREATEST(sig.creation_time,ss.last_modified))          AS "ETS",
CASE
                WHEN ss.signatures_completed_time IS NULL
                THEN 'FALSE'
                ELSE 'TRUE'
            END                                                        AS "FULLY_EXECUTED"
        FROM
            goodlife.subscription_sales ss
        LEFT JOIN
            goodlife.journalentries je
        ON
            je.ref_center = ss.subscription_center
            AND je.ref_id = ss.subscription_id
            AND je.jetype = 1
        LEFT JOIN
            goodlife.journalentry_signatures jes
        ON
            jes.journalentry_id = je.id
        LEFT JOIN
            goodlife.signatures sig
        ON
            sig.center = jes.signature_center
            AND sig.id = jes.signature_id
        GROUP BY
            ss.subscription_center||'ss'||ss.subscription_id,
            ss.signatures_completed_time) biview
WHERE
    biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
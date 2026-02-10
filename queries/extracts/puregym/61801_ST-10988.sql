-- The extract is extracted from Exerp on 2026-02-08
-- Extract to report on ADDACS files
WITH PARAMS AS materialized
(
   SELECT 
      CAST($$from_date$$ AS BIGINT) AS FROMDATE,  
      CAST($$to_date$$ AS BIGINT) AS TODATE
),
cte_acl AS Materialized (
   SELECT 
      AGREEMENT_CENTER,
      AGREEMENT_ID,
      AGREEMENT_SUBID,
      ENTRY_TIME, 
      LOG_DATE,
      STATE,
      CLEARING_IN,
      TEXT
   FROM 
      params, 
      agreement_change_log 
   WHERE 
      ENTRY_TIME >= params.FROMDATE
      AND ENTRY_TIME <= params.TODATE
      AND AGREEMENT_CENTER IN ($$scope$$)
)
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "P Number",
    CASE
        WHEN p.EXTERNAL_ID IS NULL
        THEN vp.EXTERNAL_ID
        ELSE p.EXTERNAL_ID
    END                                                                    AS "External ID",
    pag.REF                                                                AS "BACS reference",
    TO_CHAR(longtodatec(cte_acl.ENTRY_TIME, cte_acl.AGREEMENT_CENTER),'YYYY-mm-DD') AS "Entry Date",
    TO_CHAR(cte_acl.LOG_DATE,'YYYY-mm-DD')                                     AS "Log date",
    CASE cte_acl.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END      AS "Agreement State Change",
    cte_acl.TEXT AS "Reason",
    ci.ID    AS "File ID"
FROM
    cte_acl
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = cte_acl.AGREEMENT_CENTER
AND ar.ID = cte_acl.AGREEMENT_ID
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
LEFT JOIN
    persons vp
ON
    vp.CENTER = p.CURRENT_PERSON_CENTER
AND vp.ID = p.CURRENT_PERSON_ID
JOIN
    CLEARING_IN ci
ON
    ci.ID = cte_acl.CLEARING_IN
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.center = cte_acl.AGREEMENT_CENTER
AND pag.id = cte_acl.AGREEMENT_ID
AND pag.SUBID = cte_acl.AGREEMENT_SUBID
WHERE
    UPPER(ci.FILENAME) LIKE '%ADDACS%'

 WITH
     params AS MATERIALIZED
     (
         SELECT
             CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(CURRENT_TIMESTAMP)-$$offset$$-cast('1970-01-01 00:00:00' as date))::bigint*24*3600*1000 END AS FROMDATE,
             (TRUNC(CURRENT_TIMESTAMP+1)-cast('1970-01-01 00:00:00' as date))::bigint*24*3600*1000                                 AS TODATE
         
     )
 SELECT
     ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "P Number",
     CASE
         WHEN p.EXTERNAL_ID IS NULL
         THEN vp.EXTERNAL_ID
         ELSE p.EXTERNAL_ID
     END                                                                                                                                                                                                        AS "External ID",
     pag.REF                                                                                                                                                                                                        AS "BACS reference",
     TO_CHAR(longtodatec(acl.ENTRY_TIME,acl.AGREEMENT_CENTER),'YYYY-mm-DD')                                                                                                                                                                                                        AS "Entry Date",
     TO_CHAR(acl.LOG_DATE,'YYYY-mm-DD')                                                                                                                                                                                                        AS "Log date",
     CASE acl.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN  'Signature missing'  ELSE 'UNDEFINED' END AS "Agreement State Change",
     acl.TEXT                                                                                                                                                                                                        AS "Reason",
     ci.ID                                                                                                                                                                                                        AS "File ID"
 FROM
     AGREEMENT_CHANGE_LOG acl
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = acl.AGREEMENT_CENTER
     AND ar.ID = acl.AGREEMENT_ID
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
     ci.ID = acl.CLEARING_IN
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pag.center = acl.AGREEMENT_CENTER
     AND pag.id = acl.AGREEMENT_ID
     AND pag.SUBID = acl.AGREEMENT_SUBID
 CROSS JOIN
     params
 WHERE
         UPPER(ci.FILENAME) LIKE '%ADDACS%'
     AND acl.ENTRY_TIME >= params.fromdate
     AND acl.AGREEMENT_CENTER in ($$scope$$)

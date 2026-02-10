-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT c.SHORTNAME,  SUM(acc.AMOUNT) AS AMOUNT  FROM
     ACCOUNT_TRANS acc
 INNER JOIN AR_TRANS art
 ON
      art.REF_CENTER = acc.CENTER
     AND art.REF_ID = acc.ID
      AND art.REF_SUBID = acc.SUBID
 INNER JOIN
 ACCOUNTS a
 ON acc.CREDIT_ACCOUNTCENTER = a.CENTER
 and acc.CREDIT_ACCOUNTID = a.ID
 INNER JOIN
 CENTERS c
 ON c.ID = art.REF_CENTER
 WHERE
 art.REF_TYPE = 'ACCOUNT_TRANS'
 -- AND a.EXTERNAL_ID IN ('00320')
 AND acc.TEXT like 'Automatic placement: Saferpay Test - 02-05-2016%'
 --AND art.due_date = TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM')
 and c.COUNTRY = 'IT'
 GROUP BY  c.SHORTNAME
 ORDER BY c.SHORTNAME

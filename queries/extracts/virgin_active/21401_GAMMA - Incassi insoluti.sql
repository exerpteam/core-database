-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as personId,
 c.EXTERNAL_ID,
 agr.TEXT,
 art3.AMOUNT,
 LOngToDate(art3.TRANS_TIME) AS PAYMENT_DATE,
 CAST(CASE ad.EXTERNAL_ID
                          WHEN '01852' THEN '99'
                          WHEN '01853' THEN '98'
                          WHEN '11707' THEN '97'
                          WHEN '01850' THEN '01'
                          WHEN '00320' THEN '02'
                          WHEN '00340' THEN '03'
                          WHEN '00360' THEN '04'
                          WHEN '01870' THEN '05'
  END AS INT) AS CASH_PAYMENT_METHOD,
 TRUNC(CURRENT_TIMESTAMP, 'DAY') AS IMPORTDATE,
 art3.EMPLOYEECENTER AS PAYMENT_CENTER
 FROM
         PERSONS p1
 JOIN
 ACCOUNT_RECEIVABLES ar
 on
  ar.CUSTOMERCENTER = p1.CENTER
     AND ar.CUSTOMERID = p1.ID
 AND ar.AR_TYPE = 4
 LEFT
         JOIN PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
     AND pac.ID = ar.ID
 LEFT JOIN
     PAYMENT_REQUESTS pr
 ON
   pr.CENTER = ar.CENTER
     AND pr.ID = ar.id
 LEFT JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr.INV_COLL_CENTER = prs.CENTER
     AND pr.INV_COLL_ID = prs.ID
     AND pr.INV_COLL_SUBID = prs.SUBID
 LEFT JOIN AR_TRANS art
         ON
         art.PAYREQ_SPEC_CENTER = prs.CENTER
         and art.PAYREQ_SPEC_ID = prs.ID
         and art.PAYREQ_SPEC_SUBID = prs.SUBID
 LEFT JOIN AR_TRANS ART3
     on Art.CENTER = ART3.center
         and Art.ID = ART3.ID
         and art3.SUBID > art.SUBID
         and art3.AMOUNT > 0
         and art3.TEXT NOT LIKE 'Automatic%'
         --and art3.TEXT NOT LIKE 'Transfer to%'
         and art3.REF_TYPE = 'ACCOUNT_TRANS'
 LEFT JOIN ACCOUNT_TRANS act
     ON act.CENTER = art3.REF_CENTER
         AND act.ID = art3.REF_ID
         AND act.SUBID = art3.REF_SUBID
 LEFT JOIN AGGREGATED_TRANSACTIONS agr
         ON agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
     AND agr.ID = act.AGGREGATED_TRANSACTION_ID
 LEFT JOIN ACCOUNTS ad
         ON ad.ID = act.DEBIT_ACCOUNTID
     AND ad.CENTER = act.DEBIT_ACCOUNTCENTER
 LEFT JOIN ACCOUNTS ac
         ON ac.ID = act.CREDIT_ACCOUNTID
     AND ac.CENTER = act.CREDIT_ACCOUNTCENTER
 left join centers c
 ON p1.center = c.id
 WHERE
  c.COUNTRY ='IT'
 --AND ad.EXTERNAL_ID IN('11707')
 AND ac.EXTERNAL_ID IN('11705')
 --and ((pr.req_date > TO_DATE('30/09/2016','dd/mm/YYYY') and pr.CLEARINGHOUSE_ID != 803)
 --OR (pr.req_date > TO_DATE('31/01/2017','dd/mm/YYYY') and pr.CLEARINGHOUSE_ID = 803))
 and pr.req_date  <=  ADD_MONTHS(LAST_DAY(CURRENT_TIMESTAMP::date),-2)
 and extract(DAY FROM pr.req_date) <=2
 and pr.req_date  <=  ADD_MONTHS(LAST_DAY(CURRENT_TIMESTAMP::date),-2)
 and extract(DAY FROM pr.req_date) <=2
 --and art1.PAYREQ_SPEC_CENTER = select c.ID from CENTERS c where  c.COUNTRY = 'IT' and art1.PAYREQ_SPEC_ID = 21020  and art1.PAYREQ_SPEC_SUBID = 2
 and Extract(MONTH FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(MONTH FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(YEAR FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(YEAR FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(MONTH FROM(longtodate(art3.ENTRY_TIME))) = Extract(MONTH FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(YEAR FROM(longtodate(art3.ENTRY_TIME))) = Extract(YEAR FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 AND pr.STATE IS NOT NULL
 AND ART.REF_TYPE = 'INVOICE'
 AND  OPEN_AMOUNT  < REQUESTED_AMOUNT
 GROUP BY
 CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))),
 c.EXTERNAL_ID,
 agr.TEXT,
 art3.AMOUNT,
 LOngToDate(art3.TRANS_TIME),
 CAST(CASE ad.EXTERNAL_ID
                          WHEN '01852' THEN '99'
                          WHEN '01853' THEN '98'
                          WHEN '11707' THEN '97'
                          WHEN '01850' THEN '01'
                          WHEN '00320' THEN '02'
                          WHEN '00340' THEN '03'
                          WHEN '00360' THEN '04'
                          WHEN '01870' THEN '05'
  END AS INT),
 art3.CENTER,
 art3.ID,
 art3.SUBID,
 art3.EMPLOYEECENTER,
 art3.TEXT,
 pr.REQ_DATE

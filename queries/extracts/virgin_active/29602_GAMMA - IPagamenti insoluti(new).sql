 SELECT
 CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'),CAST(p1.ID as VARCHAR(6))) as personId, CONCAT(CONCAT(CAST(agr.CENTER AS CHAR(3)),'agt'),CAST(agr.ID as VARCHAR(6))) as agrTrans, art.TEXT,  art.AMOUNT, pr.req_date, longtodate(art.ENTRY_TIME) as paymentDate,
 art.EMPLOYEECENTER
 FROM
         PERSONS p1
 INNER JOIN CENTERS c
 ON c.ID = p1.CENTER
 JOIN
 ACCOUNT_RECEIVABLES ar
 on
  ar.CUSTOMERCENTER = p1.CENTER
     AND ar.CUSTOMERID = p1.ID
 AND ar.AR_TYPE = 4
 LEFT JOIN AR_TRANS art
         ON
         art.CENTER = ar.CENTER
         and art.ID = ar.ID
 LEFT JOIN ACCOUNT_TRANS act
     ON act.CENTER = art.REF_CENTER
         AND act.ID = art.REF_ID
         AND act.SUBID = art.REF_SUBID
 LEFT JOIN AGGREGATED_TRANSACTIONS agr
         ON agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
     AND agr.ID = act.AGGREGATED_TRANSACTION_ID
 LEFT JOIN ACCOUNTS ad
         ON ad.ID = act.DEBIT_ACCOUNTID
     AND ad.CENTER = act.DEBIT_ACCOUNTCENTER
 LEFT JOIN ACCOUNTS ac
         ON ac.ID = act.CREDIT_ACCOUNTID
     AND ac.CENTER = act.CREDIT_ACCOUNTCENTER
 INNER JOIN
 PAYMENT_REQUESTS pr
 ON
 pr.CENTER =  art.PAYREQ_SPEC_CENTER
 AND
 pr.ID = art.PAYREQ_SPEC_ID
 AND
 pr.SUBID = art.PAYREQ_SPEC_SUBID
 INNER JOIN
 PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
 prs.CENTER = art.PAYREQ_SPEC_CENTER
 AND
 prs.ID = art.PAYREQ_SPEC_ID
 AND
 prs.SUBID = art.PAYREQ_SPEC_SUBID
 where
  p1.CENTER = 213
 -- and p1.ID = 22401
 --and ((pr.req_date > TO_DATE('30/09/2016','dd/mm/YYYY') and pr.CLEARINGHOUSE_ID != 803)
 --OR (pr.req_date > TO_DATE('31/01/2017','dd/mm/YYYY') and pr.CLEARINGHOUSE_ID = 803))
 and Extract(DAY FROM pr.req_date) <=2
 and Extract(MONTH FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(MONTH FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(YEAR FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(YEAR FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(MONTH FROM(longtodate(art.ENTRY_TIME))) = Extract(MONTH FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and Extract(YEAR FROM(longtodate(art.ENTRY_TIME))) = Extract(YEAR FROM(ADD_MONTHS(CURRENT_TIMESTAMP,-1)))
 and art.AMOUNT > 0
 and pr.req_date  <=  ADD_MONTHS(LAST_DAY(CURRENT_TIMESTAMP::date),-2)
 and art.EMPLOYEECENTER = 100
 and art.TEXT IN('Payment into account', 'Manual registered payment of request: Payment open request')

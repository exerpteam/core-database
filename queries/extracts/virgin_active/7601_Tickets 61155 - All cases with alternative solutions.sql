 SELECT
     cc.PERSONCENTER || 'p' || cc.PERSONID pid,
     ccr.REQ_DATE,
     ccr.REF,
     ccr.REQ_AMOUNT,
     CASE
         WHEN TRUNC(longToDate(MIN(pr.ENTRY_TIME))) <= TRUNC(ccr.REQ_DATE)
         THEN 'Case A: CAN BE UPDATED'
         WHEN TRUNC(longToDate(MIN(pr.ENTRY_TIME))) > TRUNC(ccr.REQ_DATE)
         THEN 'Case B: MIGHT BE UPDATED'
         WHEN MIN(pr.ENTRY_TIME) IS NULL
         THEN 'Case C: CAN NOT BE UPDATED'
         ELSE 'FAIL'
     END solution
 FROM
     CASHCOLLECTION_REQUESTS ccr
 JOIN
     CASHCOLLECTIONCASES cc
 ON
     cc.CENTER = ccr.CENTER
     AND cc.ID = ccr.ID
     AND cc.MISSINGPAYMENT = 1
     AND cc.CLOSED = 0
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = cc.PERSONCENTER
     AND ar.CUSTOMERID = cc.PERSONID
     AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_REQUESTS pr
 ON
     pr.CENTER = ar.CENTER
     AND pr.ID = ar.ID
 WHERE
     ccr.STATE IN (-1,0)
     AND ccr.PAYMENT_REQUEST_CENTER IS NULL
     and ccr.REQ_AMOUNT > 0
 GROUP BY
     cc.PERSONCENTER,
     cc.PERSONID ,
     ccr.REF,
     ccr.REQ_DATE ,
     ccr.REQ_AMOUNT

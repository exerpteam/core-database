-- private debts that are older than 2 years

SELECT 
   sq.Member_ID AS "ExerpId",
   'Clean-up AR balance' AS "Text",
   -sq.UNSETTLED_AMOUNT AS "Amount",
   sq.ACCOUNT_TYPE
FROM
(
SELECT 
  p.CENTER||'p'||p.ID as Member_ID, 
  p.FULLNAME, 
  DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS PERSON_TYPE,
  DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
  art.UNSETTLED_AMOUNT,
  TO_CHAR(longtodateC(art.ENTRY_TIME,p.CENTER),'YYYY-MM-DD HH24:MI') AS ENTRY_TIME,
  TO_CHAR(longtodateC(art.TRANS_TIME,p.CENTER),'YYYY-MM-DD HH24:MI') AS TRANS_TIME,
  TO_CHAR(art.DUE_DATE, 'YYYY-MM-DD') As Due_Date, 
  art.STATUS AS PAYMENT_STATUS,
  DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') AS ACCOUNT_TYPE,
  CASE when r.status  = 1 and ar.AR_TYPE = 4
  THEN
    'YES'
  END AS "Other Payer"
FROM
  AR_TRANS art
JOIN
  ACCOUNT_RECEIVABLES ar
ON
  ar.CENTER = art.CENTER AND ar.ID = art.ID 
JOIN
  PERSONS p
ON    
  p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID 
LEFT JOIN
  RELATIVES r
ON
  r.RTYPE = 12
  AND r.RELATIVECENTER = p.center
  AND r.RELATIVEID = p.id
  AND r.STATUS = 1
WHERE 
  p.PERSONTYPE <> 4 AND 
  art.STATUS in ('NEW','OPEN') AND
  (art.DUE_DATE < exerpsysdate() - 730 OR art.due_DATE is null ) AND
  art.REF_TYPE in ('INVOICE','ACCOUNT_TRANS') AND
  p.CENTER in (:Scope) AND
  longtodateC(art.ENTRY_TIME,p.CENTER) < exerpsysdate()-730 AND
  longtodateC(ar.LAST_ENTRY_TIME,p.CENTER) < exerpsysdate()-730 AND
  art.UNSETTLED_AMOUNT < 0
) sq
WHERE 
 "Other Payer" is null
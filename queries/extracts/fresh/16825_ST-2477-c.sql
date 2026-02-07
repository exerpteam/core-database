-- All active private customers with a positive balance more than 3 years
SELECT 
   sq.Member_ID AS "ExerpId",
   'Clean-up AR balance' AS "Text",
   -sq.BALANCE AS "Amount",
   sq.ACCOUNT_TYPE
FROM
(
SELECT 
  p.CENTER||'p'||p.ID as Member_ID, 
  p.FULLNAME, 
  DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS PERSON_TYPE,
  DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
  ar.BALANCE AS BALANCE,
  DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') AS ACCOUNT_TYPE,
  TO_CHAR(longtodateC(ar.LAST_ENTRY_TIME,p.CENTER),'YYYY-MM-DD HH24:MI') AS LAST_ENTRY_TIME,
  CASE when r.status  = 1 and ar.AR_TYPE = 4
  THEN
    'YES'
  END AS "Other Payer"
FROM
  ACCOUNT_RECEIVABLES ar
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
  p.CENTER in (:Scope) AND
  p.STATUS = 1 AND
  longtodateC(ar.LAST_ENTRY_TIME,p.CENTER) < exerpsysdate()-365*3 AND
  ar.BALANCE > 0 
) sq
WHERE 
 "Other Payer" is null
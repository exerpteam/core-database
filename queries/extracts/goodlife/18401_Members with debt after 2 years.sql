SELECT
  p.CENTER||'p'||p.ID AS "Person ID", 
  p.FULLNAME AS "Person Name", 
  CASE WHEN 
    p.STATUS = 0 THEN 'Lead' 
    WHEN p.STATUS = 1 THEN 'Active'
    WHEN p.STATUS = 2 THEN 'Inactive'
    WHEN p.STATUS = 3 THEN 'Temporary Inactive'
    WHEN p.STATUS = 4 THEN 'Transferred'
    WHEN p.STATUS = 5 THEN 'Duplicate'
    WHEN p.STATUS = 6 THEN 'Prospect'
    WHEN p.STATUS = 7 THEN 'Deleted'
    WHEN p.STATUS = 8 THEN 'Anonmized'
    WHEN p.STATUS = 9 THEN 'Contact'
  ELSE 'Unknown'
  END AS "Person Status",
  TO_CHAR(LongtodateC(ar.LAST_ENTRY_TIME, ar.CENTER),'YYYY-MM-DD') AS "Most recent transaction date",
  ar.BALANCE AS "Account Balance",
  TO_CHAR(LongtodateC(ccc.START_DATETIME, ccc.CENTER),'YYYY-MM-DD')  AS "Debt collection start date"
FROM
  ACCOUNT_RECEIVABLES ar
JOIN
  PERSONS p
ON    
  p.CENTER = ar.CUSTOMERCENTER 
  AND p.ID = ar.CUSTOMERID 
  AND ar.AR_TYPE = 4 
JOIN 
  CASHCOLLECTIONCASES ccc
ON
   ccc.PERSONCENTER = p.CENTER
   AND ccc.PERSONID = p.ID
WHERE 
  ccc.CLOSED = false
  AND ccc.missingpayment = true
  AND (ar.LAST_ENTRY_TIME + 86400000 * CAST(:Days_Since_Last_Activity_On_Account AS Bigint) <= GETSTARTOFDAY(CAST (CAST (:Request_Date AS DATE) AS TEXT),p.CENTER))
    
 
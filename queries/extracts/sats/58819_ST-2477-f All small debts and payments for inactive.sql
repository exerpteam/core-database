-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2477
-- Lists all debt and positive balances for inactive members that is below 10 SEK, 10 NOK and 1 EUR, no matter how old the debt/positive balance is
SELECT 
  p.CENTER||'p'||p.ID as Member_ID, 
  p.FULLNAME, 
  CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS PERSON_TYPE,
  CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS PERSON_STATUS,
  ar.BALANCE AS BALANCE,
  CASE ar.AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' WHEN 6 THEN 'installment' END AS ACCOUNT_TYPE,
  TO_CHAR(longtodate(ar.LAST_ENTRY_TIME),'YYYY-MM-DD HH24:MI') AS LAST_ENTRY_TIME
FROM
  ACCOUNT_RECEIVABLES ar
JOIN
  PERSONS p
ON    
  p.CENTER = ar.CUSTOMERCENTER 
  AND p.ID = ar.CUSTOMERID 
WHERE 
  p.PERSONTYPE <> 4 
  AND p.CENTER in (:Scope) 
  AND p.STATUS = 2  -- inactive
  AND 
  ((ar.BALANCE > -10 AND ar.BALANCE < 0) OR (ar.BALANCE < 10 AND ar.BALANCE > 0))
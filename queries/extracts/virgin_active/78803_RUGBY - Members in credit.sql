-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 c.shortname as Club,
     p.center||'p'||p.id as MembershipNumber,
 p.fullname as MemberName,
     ar.BALANCE as PaymentAccountBalance,
 CASE  p.STATUS  WHEN 0 THEN  'Lead'  WHEN 1 THEN  'Active'  WHEN 2 THEN  'Inactive'  WHEN 3 THEN  'TemporaryInacttive'  WHEN 4 THEN  'Transferred'  WHEN 5 THEN  'Duplicate'  WHEN 6 THEN  'Prospect'  WHEN 7 THEN  'Deleted'  WHEN 8 THEN  'Anonymised'  WHEN 9 THEN  'Contact' END as personstatus
 FROM
     persons p
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
     AND ar.CUSTOMERID = p.id
 JOIN
 Centers c
 ON
 p.center = c.ID
 WHERE
     p.CENTER IN (75)
     AND ar.AR_TYPE = 4
     AND ar.BALANCE > 0

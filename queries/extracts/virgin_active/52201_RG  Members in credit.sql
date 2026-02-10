-- The extract is extracted from Exerp on 2026-02-08
-- Used to show member credits for Covid-19 refunds
 SELECT
 c.shortname as Club,
     p.center||'p'||p.id as MembershipNumber,
 p.fullname as MemberName,
     ar.BALANCE as PaymentAccountBalance,
	 ar.AR_TYPE,
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
	p.center||'p'||p.id = '40p90218'
     --p.CENTER IN
 -- (
         -- '76',
 -- '29',
 -- '30',
 -- '437',
 -- '33',
 -- '34',
 -- '35',
 -- '27',
 -- '36',
 -- '421',
 -- '405',
 -- '38',
 -- '438',
 -- '40',
 -- '39',
 -- '47',
 -- '48',
 -- '12',
 -- '51',
 -- '9',
 -- '955',
 -- '56',
 -- '954',
 -- '57',
 -- '59',
 -- '415',
 -- '2',
 -- '60',
 -- '61',
 -- '422',
 -- '452',
 -- '15',
 -- '6',
 -- '68',
 -- '69',
 -- '410',
 -- '16',
 -- '71',
 -- '75',
 -- '953',
 -- '425',
 -- '408')
     --AND ar.AR_TYPE = 4
     AND ar.BALANCE > 0

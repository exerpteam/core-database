select
DISTINCT
c.SHORTNAME, CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as personId, p1.FULLNAME as nominativo,
CASE pr.STATE  WHEN 1 THEN  'PS_NEW'  WHEN 2 THEN  'PS_SENT'  WHEN 3 THEN  'PS_DONE'  WHEN 5 THEN  'PS_REJECTED_BY_CLEARINGHOUSE'  WHEN 12 THEN  'PS_FAIL_NO_CREDITOR'  WHEN 17 THEN 'PS_FAIL_REJ_DEB_REVOKED' END "Stato", 
  art.TEXT AS DescrizioneMovimento, invl.TEXT as ProdottoMovimento, REQUESTED_AMOUNT AS importoRid, invl.TOTAL_AMOUNT as importoMovimento, pr.REQ_DATE as scadenza
 
 
FROM 

	PERSONS p1
INNER JOIN CENTERS c

ON p1.CENTER = c.ID

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
	ON art.PAYREQ_SPEC_SUBID = prs.SUBID
	and art.PAYREQ_SPEC_ID = prs.ID
	and art.PAYREQ_SPEC_CENTER = prs.CENTER
LEFT JOIN INVOICELINES invl

 on invl.ID = art.REF_ID
AND invl.CENTER = art.REF_CENTER





WHERE 
--PR.center = 102 AND
c.COUNTRY = 'IT'
 and extract(month from pr.req_date) = EXTRACT(month FROM  ADD_MONTHS(CURRENT_TIMESTAMP,-1))
and extract(year from  pr.req_date) = extract(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))
and extract(day from pr.req_date) <= 2
AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
AND invl.TOTAL_AMOUNT <> 0
AND invl.TEXT != 'PT Family'

AND art.COLLECTED_AMOUNT <> 0

AND art.TEXT LIKE 'PT%'

UNION ALL 
SELECT c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId, p.FULLNAME as nominativo, '' as STATE,
invl.TEXT AS DescrizioneMovimento, pr.NAME as ProdottoMovimento, SUM(arm.AMOUNT) AS importoRid, SUM(arm.AMOUNT) as importoMovimento, MAX(LongToDate(ar1.ENTRY_TIME)) as scadenza
FROM 
	 AR_TRANS ar1
INNER JOIN ACCOUNT_TRANS act
ON 
ar1.REF_CENTER = act.CENTER
AND
ar1.REF_ID = act.ID
AND
ar1.REF_SUBID = act.SUBID
AND
ar1.REF_TYPE = 'ACCOUNT_TRANS'


INNER JOIN ART_MATCH arm
ON 
arm.ART_PAYING_CENTER = ar1.CENTER
AND
arm.ART_PAYING_ID = ar1.ID
AND
arm.ART_PAYING_SUBID = ar1.SUBID

INNER JOIN AR_TRANS ar2
ON 
arm.ART_PAID_CENTER = ar2.CENTER
AND
arm.ART_PAID_ID = ar2.ID
AND
arm.ART_PAID_SUBID = ar2.SUBID
AND ar2.REF_TYPE = 'INVOICE'

INNER JOIN INVOICES inv

ON inv.CENTER = ar2.REF_CENTER
AND
inv.ID = ar2.REF_ID
INNER JOIN INVOICELINES invl

ON inv.CENTER = invl.CENTER
AND
inv.ID = invl.ID
INNER JOIN PRODUCTS pr
ON invl.PRODUCTCENTER = pr.CENTER
AND
invl.PRODUCTID = pr.ID
INNER JOIN PERSONS p
ON p.CENTER = inv.PAYER_CENTER
AND
p.ID = inv.PAYER_ID
INNER JOIN CENTERS c
ON c.ID = p.CENTER



	WHERE 
--p.CENTER = 212
 --  AND p.ID = 4883
     c.COUNTRY = 'IT'
    AND ar1.TEXT LIKE 'Payment%'
  --AND inv.RECEIPT_ID IS NOT NULL
    AND ar2.TEXT LIKE '%Annual Fee%'
	 and extract(month from LongToDate(ar1.ENTRY_TIME)) = EXTRACT(month FROM  ADD_MONTHS(CURRENT_TIMESTAMP,-1))
and extract(year from  LongToDate(ar1.ENTRY_TIME)) = extract(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))
AND p.PERSONTYPE = 2
GROUP BY c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))), p.FULLNAME, 
invl.TEXT, pr.NAME

UNION ALL

SELECT
   	c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId, p.FULLNAME as nominativo, '' as STATE,
invl.TEXT AS DescrizioneMovimento, pr.NAME as ProdottoMovimento, SUM(arm.AMOUNT) AS importoRid, SUM(arm.AMOUNT) as importoMovimento, MAX(LongToDate(ar1.ENTRY_TIME)) as scadenza
FROM
	AR_TRANS ar1
INNER JOIN 
ACCOUNT_TRANS act
ON
ar1.REF_CENTER = act.CENTER
AND 	
ar1.REF_ID = act.ID
AND
ar1.REF_SUBID = act.SUBID

INNER JOIN ART_MATCH arm
ON 
arm.ART_PAYING_CENTER = ar1.CENTER
AND
arm.ART_PAYING_ID = ar1.ID
AND
arm.ART_PAYING_SUBID = ar1.SUBID

INNER JOIN
AR_TRANS ar2
ON 
arm.ART_PAID_CENTER = ar2.CENTER
AND
arm.ART_PAID_ID = ar2.ID
AND
arm.ART_PAID_SUBID = ar2.SUBID
AND ar2.REF_TYPE = 'INVOICE'

INNER JOIN INVOICES inv

ON inv.CENTER = ar2.REF_CENTER
AND
inv.ID = ar2.REF_ID
INNER JOIN INVOICELINES invl

ON inv.CENTER = invl.CENTER
AND
inv.ID = invl.ID
INNER JOIN PRODUCTS pr
ON invl.PRODUCTCENTER = pr.CENTER
AND
invl.PRODUCTID = pr.ID
INNER JOIN PERSONS p
ON p.CENTER = inv.PAYER_CENTER
AND
p.ID = inv.PAYER_ID
INNER JOIN CENTERS c
ON c.ID = p.CENTER

WHERE
--ar1.CENTER = 107
--AND ar1.ID = 40524
	c.COUNTRY = 'IT'
	AND EXTRACT(MONTH FROM LongToDate(ar1.ENTRY_TIME)) = 9
    AND EXTRACT(YEAR FROM LongToDate(ar1.ENTRY_TIME)) = 2017
AND ar1.REF_TYPE = 'ACCOUNT_TRANS'
AND ar2.TEXT LIKE 'PT%'
AND ar1.Text LIKE 'Payment into%'
 and extract(month from LongToDate(ar1.ENTRY_TIME)) = EXTRACT(month FROM  ADD_MONTHS(CURRENT_TIMESTAMP,-1))
and extract(year from LongToDate(ar1.ENTRY_TIME)) = extract(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))

GROUP BY c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))), p.FULLNAME, 
invl.TEXT, pr.NAME


Order by personId
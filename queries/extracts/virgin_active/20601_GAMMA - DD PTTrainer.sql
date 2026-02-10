-- The extract is extracted from Exerp on 2026-02-08
--  
select SHORTNAME as club,
 count(*) as numero,
sum(AMOUNT)*-1 AS IMPORTO
 
from(
select DISTINCT art.CENTER, art.ID, art.SUBID, C.SHORTNAME, art.AMOUNT
FROM 

  

    PAYMENT_REQUESTS pr


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
LEFT JOIN INVOICES inv

on inv.center = invl.center and inv.id = invl.id 

LEFT JOIN CENTERS c
ON C.ID = PRS.CENTER
 where (ART.text like '%PT Operating Club%' or ART.text like'%PT EX GI Operating Club%') and C.COUNTRY = 'IT'
and art.due_date = $$data$$) art

GROUP BY SHORTNAME
ORDER BY SHORTNAME
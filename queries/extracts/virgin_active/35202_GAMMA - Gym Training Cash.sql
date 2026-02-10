-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT c.SHORTNAME as Club, P.FULLNAME as Nominativo, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as PersonId, inv.TEXT as motivazione, pr.NAME, invl.QUANTITY as Quantità,
sum(invl.TOTAL_AMOUNT) as Prezzo,
TRUNC(LongToDate(inv.TRANS_TIME)) as dataAcquisto

FROM PRODUCTS pr
INNER JOIN
INVOICELINES invl
ON 
pr.CENTER = invl.PRODUCTCENTER
AND
pr.ID = invl.PRODUCTID
INNER JOIN INVOICES
inv
ON invl.CENTER = inv.CENTER
AND invl.id = INV.id
INNER JOIN PERSONS P
ON 
p.ID = inv.PAYER_ID
AND
p.CENTER = inv.PAYER_CENTER
INNER JOIN 
CENTERS c
ON 
c.ID = p.CENTER
WHERE
 pr.NAME = 'GYM TRAINING'
AND
c.COUNTRY = 'IT'
AND
TRUNC(LongToDate(inv.TRANS_TIME)) BETWEEN $$dataDa$$ AND $$dataA$$
AND inv.TEXT like 'Shop sale%'
AND p.CENTER = $$club$$

GROUP BY 
c.SHORTNAME, P.FULLNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))), pr.NAME, invl.QUANTITY, TRUNC(LongToDate(inv.TRANS_TIME)), inv.TEXT

ORDER BY c.SHORTNAME, P.FULLNAME
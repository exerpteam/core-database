-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT c.shortname,
CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId,
p.FULLNAME,
arpaying.SUBID,arpaying.TEXT as descrizionePagamento,
inv.TEXT as descrizioneFattura,
 LongToDate(arpaid.ENTRY_TIME) as dataCreazione, 
 LongToDate(arpaid.TRANS_TIME) as dataEmissione, 
LongToDate(arpaying.TRANS_TIME) as dataPagamento,
artm.AMOUNT as importoPagato

 FROM ART_MATCH artm
inner join AR_TRANS arpaying
on artm.ART_PAYING_CENTER = arpaying.CENTER
AND artm.ART_PAYING_ID = arpaying.ID
AND artm.ART_PAYING_SUBID = arpaying.SUBID
INNER JOIN AR_TRANS arpaid
on artm.ART_PAID_CENTER = arpaid.CENTER
AND artm.ART_PAID_ID = arpaid.ID
AND artm.ART_PAID_SUBID = arpaid.SUBID
INNER JOIN
PAYMENT_REQUESTS pr
ON 
pr.CENTER = arpaid.PAYREQ_SPEC_CENTER
AND
pr.ID = arpaid.PAYREQ_SPEC_ID
AND
pr.SUBID = arpaid.PAYREQ_SPEC_SUBID
INNER JOIN INVOICES inv
ON
inv.CENTER = arpaid.REF_CENTER
AND
inv.ID = arpaid.REF_ID
INNER JOIN INVOICELINES invl
ON
invl.CENTER = arpaid.REF_CENTER
AND
invl.ID = arpaid.REF_ID
INNER JOIN PERSONS p
ON
p.CENTER = inv.PAYER_CENTER
INNER JOIN CENTERS c
ON c.ID = arpaying.CENTER
AND
p.ID = inv.PAYER_ID
WHERE 
arpaying.TEXT = 'Payment into account'
AND
longToDate(arpaying.TRANS_TIME) BETWEEN  longToDate(arpaid.ENTRY_TIME) AND  longToDate(arpaid.TRANS_TIME)

AND 
Extract(MONTH FROM  longToDate(arpaid.TRANS_TIME)) = 1
AND
Extract(YEAR FROM  longToDate(arpaid.TRANS_TIME)) = 2017
AND
extract(DAY FROM arpaid.DUE_DATE) = 1
AND
extract(MONTH FROM arpaid.DUE_DATE) = 1
AND
extract(YEAR FROM arpaid.DUE_DATE) = 2017 

--AND artm.ART_PAYING_CENTER = 224
AND c.COUNTRY ='IT'
ORDER BY
c.shortname,
p.FULLNAME

 
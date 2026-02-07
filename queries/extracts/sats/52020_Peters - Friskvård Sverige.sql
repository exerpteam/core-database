 SELECT DISTINCT
     inv.PAYER_CENTER,
     inv.PAYER_ID,
     inv.CENTER || 'inv' || inv.id invID,
     invl.*,
     rel.STATUS,
     rel.RELATIVECENTER || 'p' || rel.RELATIVEID company,
     rel.RELATIVECENTER || 'p' || rel.RELATIVEID || 'ca' || rel.RELATIVESUBID agreement_key,
     longToDate(inv.ENTRY_TIME) entry_time,
     prod.NAME,
     prod2.NAME,
         p.EXTERNAL_ID AS "ExternalId"
 FROM
     INVOICELINES invl
 JOIN PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
         and prod.PTYPE = 2
 JOIN INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.ID = invl.ID
 LEFT JOIN RELATIVES rel
 ON
     rel.CENTER = inv.PAYER_CENTER
     AND rel.ID = inv.PAYER_ID
     AND rel.RTYPE = 3
     AND rel.STATUS = 1
  JOIN INVOICES inv2
 ON
     inv2.PAYER_CENTER = inv.PAYER_CENTER
     AND inv2.PAYER_ID = inv.PAYER_ID
  JOIN INVOICELINES invl2
 ON
     invl2.CENTER = inv2.CENTER
     AND invl2.ID = inv2.ID
  JOIN PRODUCTS prod2
 ON
     prod2.CENTER = invl2.PRODUCTCENTER
     AND prod2.ID = invl2.PRODUCTID
 JOIN PERSONS p
         ON p.CENTER = inv.PAYER_CENTER
         AND p.ID = inv.PAYER_ID
 WHERE
     prod.PTYPE = 2
     AND prod2.PTYPE = 5
     AND prod.NAME LIKE 'Friskvårds fee%'
 and inv.TRANS_TIME  >= datetolong(to_char(current_timestamp - cast(:Days_back_in_time as integer),'yyyy-mm-dd HH24:MI'))
 and inv.TRANS_TIME <= (datetolong(to_char(current_timestamp - 1, 'yyyy-mm-dd HH24:MI'))+ 24*3600*1000)

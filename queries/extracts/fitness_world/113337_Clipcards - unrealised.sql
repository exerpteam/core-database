-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT

    cc.OWNER_CENTER || 'p' ||  cc.OWNER_ID  "Member ID"
  , prod.NAME "Product Name"
  , invl.TOTAL_AMOUNT / invl.QUANTITY "product price"
  , cc.CLIPS_INITIAL "number of clips"
  , invl.TOTAL_AMOUNT / invl.QUANTITY / cc.CLIPS_INITIAL "price per clip"
  , cc.CLIPS_LEFT "unrealised clips"
  , (invl.TOTAL_AMOUNT / invl.QUANTITY / cc.CLIPS_INITIAL) * cc.clips_left "remaining balance"
  , case  when inv.TEXT = 'Clipcard sale API' then 'API' else 'CASH_REGISTER' end "type of sale"
  , trunc(longToDateC(inv.TRANS_TIME,inv.CENTER)) "sale date"
  , case when inv.TEXT = 'Clipcard sale API' then artp.INFO else null end "vendor tx code"
  
FROM
    CLIPCARDS cc
JOIN
    INVOICELINES invl
ON
    invl.CENTER = cc.INVOICELINE_CENTER
    AND invl.ID = cc.INVOICELINE_ID
    AND invl.SUBID = cc.INVOICELINE_SUBID
join PRODUCTS prod on prod.CENTER = invl.PRODUCTCENTER and     prod.ID = invl.PRODUCTID
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
left join AR_TRANS art on art.REF_TYPE = 'INVOICE' and art.REF_CENTER =  inv.CENTER and art.REF_ID = inv.ID and art.AMOUNT = (invl.TOTAL_AMOUNT * -1)
left join ART_MATCH m on m.ART_PAID_CENTER = art.CENTER and 
m.ART_PAID_ID = art.ID and 
m.ART_PAID_SUBID = art.SUBID 
left join AR_TRANS artp on artp.CENTER = m.ART_PAYING_CENTER and 
artp.ID = m.ART_PAYING_ID and 
artp.SUBID = m.ART_PAYING_SUBID
WHERE
    cc.OWNER_CENTER in ($$scope$$)
    --AND cc.OWNER_ID = 44660
    AND cc.FINISHED = 0
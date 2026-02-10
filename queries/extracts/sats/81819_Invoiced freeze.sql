-- The extract is extracted from Exerp on 2026-02-08
--  
 select
 invl.person_CENTER ||'p'|| invl.person_id,
 invl.text,
 invl.TOTAL_AMOUNT,
 invl.center ||'inv'|| invl.id,
 prod.name,
 cn.CENTER ||'cred'|| cn.id
 from INVOICE_LINES_MT invl
 join products prod
 on
 invl.productcenter = prod.center
 and
 invl.productid = prod.id
 join invoices i
 on
 i.center = invl.center
 and
 i.id = invl.id
 left join
    CREDIT_NOTES cn
 on cn.INVOICE_CENTER = i.CENTER
 and cn.INVOICE_ID = i.ID
 where
 --invl.person_CENTER = 429 and invl.person_id = 1395
 (invl.person_CENTER,invl.person_id) in (:memberid)
 and invl.total_amount not in (0,149)
 and invl.text like 'Bero%%'

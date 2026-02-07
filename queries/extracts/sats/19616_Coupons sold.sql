SELECT
		c.NAME,
        crt.CENTER,
        sats.longToDate(crt.TRANSTIME) as transactiontime,
		invl.person_center||'p'||invl.person_id as customer,
        customer.fullname,
        ext.TXTVALUE,	
        crt.EMPLOYEECENTER||'emp'||crt.EMPLOYEEID as employee,
        cen.NAME,
		p.name
    
FROM
    INVOICELINES invl
    
join PERSONS customer on customer.center = invl.PERSON_CENTER and customer.id = invl.PERSON_ID
JOIN PRODUCTS p
ON
    p.CENTER = invl.PRODUCTCENTER
AND p.id = invl.PRODUCTID
JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
AND inv.id = invl.id
JOIN CASHREGISTERTRANSACTIONS crt
ON
    crt.CENTER = inv.CASHREGISTER_CENTER
AND crt.ID = inv.CASHREGISTER_ID
AND crt.PAYSESSIONID = inv.PAYSESSIONID

LEFT join SATS.PERSON_EXT_ATTRS ext
on
     ext.PERSONCENTER = customer.CENTER
     and
     ext.PERSONID = customer.ID
     and
     ext.NAME = '_eClub_Email'

LEFT join SATS.CENTERS cen
on
     cen.ID = invl.PERSON_CENTER
JOIN SATS.CENTERS c
ON
    c.id = crt.center
WHERE
    lower(p.name) LIKE 'coupon%'
AND p.CENTER in (:scope)
and p.name in (:coupon)
order by
    p.name
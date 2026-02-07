SELECT
    crt.CENTER,
    sats.longToDate(crt.TRANSTIME) as transactiontime,
	inv.person_center||'p'||inv.person_id as customer,
    crt.EMPLOYEECENTER||'emp'||crt.EMPLOYEEID as employee,
    p.name,
    a.NAME as area
FROM
    INVOICELINES invl
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
JOIN AREA_CENTERS ac
ON
    ac.CENTER = p.CENTER
JOIN AREAS a
ON
    a.ID = ac.AREA
WHERE
    lower(p.name) LIKE 'coupon%'
AND p.CENTER in (:scope)
and p.name in (:coupon)
order by
    p.name,
    a.name
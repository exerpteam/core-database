SELECT
    p.center ||'p'|| p.id as memberid,
    p.firstname,
    p.lastname,
    prod.NAME "Product name",
    prod.globalid,
    'credit rejection fee' as text,
    invl.QUANTITY "Product sold",
    invl.TOTAL_AMOUNT "Product price",
    to_char(longtodate(inv.trans_time), 'DD-MM-YYYY HH24:MI')  "Entry date",
cn.CENTER ||'cred'|| cn.id
FROM
    INVOICES inv
JOIN
    INVOICE_LINES_mt invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID    
JOIN PERSONS p
ON
    p.id = invl.person_id
    AND p.center = invl.person_center    
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PTYPE = 2
left join
   CREDIT_NOTES cn
on cn.INVOICE_CENTER = inv.CENTER
and cn.INVOICE_ID = inv.ID
WHERE
 --   (p.center,p.id) IN ($$person) and
     inv.TRANS_TIME BETWEEN $$FromDate$$ AND $$ToDate$$     
    and prod.globalid in ($$Product_Name$$)
    
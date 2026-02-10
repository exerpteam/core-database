-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        TO_CHAR(longtodate(inv.trans_time), 'dd-MM-YYYY HH24:MI')       AS TRANSACTIONTIME,
        pr.name                                                         AS PRODUCTNAME,
        pr.external_id                                                  AS PRODUCT_EXTERNALID,
        invl.product_normal_price                                       AS PRODUCT_NORMALPRICE,
        invl.total_amount                                               AS PRODUCT_SALESPRICE,
        c.name                                                          AS CENTERNAME, 
        invl.person_center||'p'||invl.person_id                         AS PERSONID
FROM
        INVOICELINES invl

JOIN
        CENTERS c
ON
        c.id = invl.center
AND     c.country = 'IT'

JOIN
        PRODUCTS pr
ON
        pr.center = invl.productcenter
AND     pr.id = invl.productid
AND     pr.ptype = 1

JOIN
        INVOICES inv
ON
        inv.center = invl.center
AND     inv.id = invl.id

WHERE
        inv.trans_time BETWEEN :fromdate AND :todate
        
ORDER BY
transactiontime
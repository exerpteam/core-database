SELECT DISTINCT
        TO_CHAR(longtodate(inv.trans_time), 'dd-MM-YYYY HH24:MI') AS TRANSACTIONTIME,
        pr.name AS PRODUCTNAME,
        pr.external_id AS PRODUCT_EXTERNALID,
		--pr.coment AS INFO_PRODOTTO,
		SPLIT_PART(pr.coment, '-', 1) AS Stagione,
    	SPLIT_PART(pr.coment, '-', 2) AS Descrizione,
        invl.product_normal_price AS PRODUCT_NORMALPRICE,
        invl.total_amount AS PRODUCT_SALESPRICE,
        c.shortname AS CENTERNAME, 
        invl.person_center||'p'||invl.person_id AS PERSONID
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
		AND c.id in ($$scope$$)

        
ORDER BY
transactiontime


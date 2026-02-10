-- The extract is extracted from Exerp on 2026-02-08
-- Extract API used for ensuring members can only purchase either Get into PT or Kickstart once online
SELECT
p.CENTER || 'p' || p.ID "member ID",
p.external_id,
prod.GLOBALID product,
prod.name AS product_name,                          
    to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') as "Sales Date",
    to_char(longtodate(inv.TRANS_TIME),'HH24:MI') as "Sales Time",
prod.center as "Productcenter",
prod.id as "ProductID"

FROM INVOICES inv

JOIN INVOICELINES invl
ON	
    invl.CENTER = inv.CENTER
    AND invl.id = inv.iD
JOIN PERSONS p
ON
	p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN CENTERS c
ON
    c.id = invl.CENTER
JOIN PRODUCTS prod
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
JOIN PRODUCT_GROUP productGroup
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = productGroup.id
WHERE
p.external_id in (:externalid)  

    and NOT EXISTS
    (
        SELECT
            *
        FROM
            CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.id
            AND cnl.INVOICELINE_SUBID = invl.SUBID
    )
	
and prod.GLOBALID IN ('GET_INTO_PT_2_SESSIONS_*NEW_ON','KICKSTART_PT_1_SESSION')
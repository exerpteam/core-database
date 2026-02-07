-- This is the version from 2026-02-05
--  
SELECT
    ss.owner_center||'p'||ss.owner_id as customer,
    sa.EMPLOYEE_CREATOR_CENTER||'emp'||sa.EMPLOYEE_CREATOR_ID as staff,
    prod.globalid as addon_product,
    REPLACE('' || prod.PRICE, '.', ',')  AS NORMAL_UNIT_PRICE,
    longtodate(sa.creation_time) as sales_date
From
     fw.SUBSCRIPTION_ADDON sa
join fw.masterproductregister m
    on
    sa.addon_product_id = m.id
join fw.subscription_sales ss
    on 
    sa.subscription_center = ss.subscription_center
    and sa.subscription_id= ss.subscription_id
join fw.products prod
    on
    m.globalid = prod.globalid
JOIN fw.invoicelines invl
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
WHERE
    ss.owner_center in (:scope)
    and sa.creation_time >=  :sale_from_date 
    and sa.creation_time <= :sale_to_date
	and prod.globalid in (:product_globalid)
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            fw.CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.id
            AND cnl.INVOICELINE_SUBID = invl.SUBID
    )
group by
    ss.owner_center,
    ss.owner_id,
    sa.EMPLOYEE_CREATOR_CENTER,
    sa.EMPLOYEE_CREATOR_ID,
    prod.globalid,
    prod.PRICE,
    sa.creation_time
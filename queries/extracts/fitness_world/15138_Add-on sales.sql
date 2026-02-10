-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ss.owner_center || 'p' || ss.owner_id AS customer,
    sa.employee_creator_center || 'emp' || sa.employee_creator_id AS staff,
    prod.globalid AS addon_product,
    REPLACE(prod.price::text, '.', ',') AS normal_unit_price,
    longtodate(sa.creation_time) AS sales_date
FROM fw.subscription_addon sa
JOIN fw.masterproductregister m
    ON sa.addon_product_id = m.id
JOIN fw.subscription_sales ss
    ON sa.subscription_center = ss.subscription_center
   AND sa.subscription_id = ss.subscription_id
JOIN fw.products prod
    ON m.globalid = prod.globalid
WHERE
    ss.owner_center IN (:scope)
    AND sa.creation_time >= :sale_from_date
    AND sa.creation_time <= :sale_to_date
    AND prod.globalid IN (
        'ALL_IN_7',
        'KOLDING___SVØMNING',
        'EXTENDED_BCA__ADGANG_'
    )
    AND EXISTS (
        SELECT 1
        FROM fw.invoicelines invl
        WHERE invl.productid = prod.id
          AND invl.productcenter = prod.center
          AND NOT EXISTS (
              SELECT 1
              FROM fw.credit_note_lines cnl
              WHERE cnl.invoiceline_center = invl.center
                AND cnl.invoiceline_id = invl.id
                AND cnl.invoiceline_subid = invl.subid
          )
    )
GROUP BY
    ss.owner_center,
    ss.owner_id,
    sa.employee_creator_center,
    sa.employee_creator_id,
    prod.globalid,
    prod.price,
    sa.creation_time;

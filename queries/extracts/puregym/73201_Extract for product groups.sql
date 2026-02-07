SELECT
    prod.center "Product Center Id",
    cen.name "Product Center Name",
    prod.globalid "Product Global Id",
    prod.name "Product Name",
    pg.name "Product Group"
FROM
    products prod
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pgl.product_center = prod.center
AND pgl.product_id = prod.id
JOIN
    product_group pg
ON
    pg.id = pgl.product_group_id
JOIN
    centers cen
ON
    cen.id= prod.center
where prod.center in ($$scope$$)
and pg.name in ($$name$$)
ORDER BY
    pg.name
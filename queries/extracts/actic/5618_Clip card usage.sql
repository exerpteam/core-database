/**
* Creator: Exerp
* Purpose: List usages of Clipcards by selecting where products from ProductGroup 'Personal Training' is bought.
*/
SELECT
    pu.TARGET_CENTER SiteId,
    p.CENTER || 'p' || p.ID MemberId,
    p.FIRSTNAME,
    p.LASTNAME,
    longToDate(pu.USE_TIME) used
FROM
    CARD_CLIP_USAGES ccu
JOIN CLIPCARDS cc
ON
    cc.CENTER = ccu.CARD_CENTER
    AND cc.ID = ccu.CARD_ID
    AND cc.SUBID = ccu.CARD_SUBID
JOIN INVOICELINES invl
ON
    invl.CENTER = cc.INVOICELINE_CENTER
    AND invl.ID = cc.INVOICELINE_ID
    AND invl.SUBID = cc.INVOICELINE_SUBID
JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN PRODUCT_AND_PRODUCT_GROUP_LINK plink
ON
    plink.PRODUCT_CENTER = prod.CENTER
    AND plink.PRODUCT_ID = prod.ID
JOIN PRODUCT_GROUP pg
ON
    pg.ID = plink.PRODUCT_GROUP_ID
JOIN PERSONS p
ON
    p.CENTER = cc.OWNER_CENTER
    AND p.ID = cc.OWNER_ID
JOIN PRIVILEGE_USAGES pu
ON
    pu.ID = ccu.REF
WHERE
    pg.NAME = 'Personal Training'
    AND ccu.CARD_CENTER IN (:scope)
    AND pu.TARGET_START_TIME BETWEEN :from_date AND :to_date
ORDER BY
    p.CENTER,
    p.ID

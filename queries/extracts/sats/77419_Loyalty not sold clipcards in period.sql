SELECT
    p.CENTER || 'p' || p.ID "member ID",
    att.txtvalue                                     AS "Loyalty level"
    ,longtodate(pcl.ENTRY_TIME)                       AS "Level change date"
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.id = p.CENTER
JOIN
    PERSON_EXT_ATTRS Att
ON
    p.center = att.personcenter
AND p.id = att.personid
AND att.NAME = 'UNBROKENMEMBERSHIPGROUPALL'
AND att.TXTVALUE IS NOT NULL
LEFT JOIN
    PERSON_CHANGE_LOGS pcl
ON
    p.center = pcl.person_center
AND p.id = pcl.person_id
AND att.name = pcl.CHANGE_ATTRIBUTE
AND pcl.NEW_VALUE = att.txtvalue
WHERE
        p.PERSONTYPE NOT IN (2)
        AND p.STATUS IN (1,3)
        AND p.CENTER IN (:scope)
        AND NOT EXISTS
        (
                SELECT
                        1
                FROM
                        INVOICELINES invl
                JOIN
                        INVOICES inv
                        ON
                        invl.CENTER = inv.CENTER
                        AND invl.id = inv.iD
                JOIN
                        PRODUCTS prod
                        ON
                        prod.ID = invl.PRODUCTID
                        AND prod.CENTER = invl.PRODUCTCENTER
                WHERE
                        p.CENTER = invl.PERSON_CENTER
                        AND p.ID = invl.PERSON_ID
                        AND prod.globalid IN ('LOYALTY_PLATINUM_GX&CONCEPT',
                                              'LOYALTY_SILVER_GX&CONCEPT',
                                              'LOYALTY_GOLD_GX&CONCEPT',
                                              'LOYALTY_BLUE_GX&CONCEPT',
                                              'LOYALTY_BLUE_BRINGAFRIEND',
                                              'LOYALTY_GOLD_BRINGAFRIEND',
                                              'LOYALTY_PLATINUM_BRINGAFRIEND',
                                              'LOYALTY_SILVER_BRINGAFRIEND',
                                              'LOYALTY_PLATINUM_PTCOUPON1',
                                              'LOYALTY_GOLD_PTCOUPON1',
                                              'LOYALTY_SILVER_PTCOUPON1')
                        AND inv.TRANS_TIME BETWEEN (:from) AND (:to)  )
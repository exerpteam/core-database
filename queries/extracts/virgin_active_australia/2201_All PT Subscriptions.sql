-- The extract is extracted from Exerp on 2026-02-08
--  
WITH clip_data AS (
    SELECT 
        cc.OWNER_CENTER AS person_center,
        cc.OWNER_ID     AS person_id,
        SUM(cc.CLIPS_LEFT) AS total_clips
    FROM CLIPCARDS cc
    JOIN INVOICE_LINES_MT invl 
        ON cc.INVOICELINE_CENTER = invl.CENTER 
       AND cc.INVOICELINE_ID     = invl.ID 
       AND cc.INVOICELINE_SUBID  = invl.SUBID
    JOIN INVOICES inv 
        ON inv.CENTER = invl.CENTER 
       AND inv.ID     = invl.ID
    JOIN PRODUCTS prod 
        ON prod.CENTER = invl.PRODUCTCENTER 
       AND prod.ID     = invl.PRODUCTID
    WHERE (prod.CENTER, prod.ID) IN (
        SELECT link.PRODUCT_CENTER, link.PRODUCT_ID
        FROM PRODUCT_AND_PRODUCT_GROUP_LINK link
        JOIN PRODUCT_GROUP pg 
          ON pg.ID = link.PRODUCT_GROUP_ID
         AND (pg.ID in (212,227) OR pg.parent_product_group_id in (212,227))
    )
      AND cc.CANCELLED = 0
    GROUP BY cc.OWNER_CENTER, cc.OWNER_ID
)
SELECT 
    i2."CLUB",
    i2."CLUB_NAME",
    i2."Person_ID",
    i2."Person_STATUS",
    --i2."Subscription_State",
    MAX(i2."SURNAME") AS "SURNAME",
    MAX(i2."FORENAME") AS "FORENAME",
    i2."Product bought last purchase" AS "Product Purchased",
    --SUM(i2."Value OF product purchase") AS "Total Product Value",
    COALESCE(cd.total_clips,0) AS "Total Clips LEFT"
FROM (
    SELECT 
        p.EXTERNAL_ID,
        p.CENTER || 'p' || p.ID "Person_ID",
        p.CENTER "CLUB",
        c.NAME "CLUB_NAME",
        CASE p.STATUS
            WHEN 0 THEN 'LEAD'
            WHEN 1 THEN 'ACTIVE'
            WHEN 2 THEN 'INACTIVE'
            WHEN 3 THEN 'TEMPORARYINACTIVE'
            WHEN 4 THEN 'TRANSFERED'
            WHEN 5 THEN 'DUPLICATE'
            WHEN 6 THEN 'PROSPECT'
            WHEN 7 THEN 'DELETED'
            WHEN 8 THEN 'ANONYMIZED'
            WHEN 9 THEN 'CONTACT'
            ELSE 'UNKNOWN'
        END "Person_STATUS",
        CASE S.State
            WHEN 2 THEN 'ACTIVE'
            WHEN 3 THEN 'ENDED'
            WHEN 4 THEN 'FROZEN'
            WHEN 7 THEN 'WINDOW'
            WHEN 8 THEN 'CREATED'
        END "Subscription_State",
        p.LASTNAME "SURNAME",
        p.FIRSTNAME "FORENAME",
        FIRST_VALUE(i1.PRODUCT_NAME) OVER (
            PARTITION BY p.EXTERNAL_ID 
            ORDER BY i1.LAST_BILLED DESC
        ) "Product bought last purchase",
        FIRST_VALUE(i1.PRICE) OVER (
            PARTITION BY p.EXTERNAL_ID 
            ORDER BY i1.LAST_BILLED DESC
        ) "Value OF product purchase",
        MAX(i1.IN_RANGE) OVER (PARTITION BY p.EXTERNAL_ID) "IN_RANGE"
    FROM (
        SELECT 
            sa.END_DATE expiry_date,
            s.OWNER_CENTER PERSON_CENTER,
            s.OWNER_ID PERSON_ID,
            s.BILLED_UNTIL_DATE - INTERVAL '1 month' AS LAST_BILLED,
            prod.NAME PRODUCT_NAME,
            prod.PRICE,
            -1 clips_left,
            CASE WHEN sa.END_DATE IS NULL 
                      OR sa.END_DATE > current_timestamp - INTERVAL '3 months' 
                 THEN 1 ELSE 0 END AS IN_RANGE
        FROM SUBSCRIPTION_ADDON sa
        JOIN MASTERPRODUCTREGISTER mpr 
          ON mpr.ID = sa.ADDON_PRODUCT_ID
        JOIN PRODUCTS prod 
          ON prod.CENTER = sa.SUBSCRIPTION_CENTER 
         AND prod.GLOBALID = mpr.GLOBALID
        JOIN SUBSCRIPTIONS s 
          ON s.CENTER = sa.SUBSCRIPTION_CENTER 
         AND s.ID     = sa.SUBSCRIPTION_ID
        WHERE (prod.CENTER, prod.ID) IN (
            SELECT link.PRODUCT_CENTER, link.PRODUCT_ID
            FROM PRODUCT_AND_PRODUCT_GROUP_LINK link
            JOIN PRODUCT_GROUP pg 
              ON pg.ID = link.PRODUCT_GROUP_ID
             AND (pg.ID in (212,227) OR pg.parent_product_group_id in (212,227))
        )
          AND sa.CANCELLED = 0
          AND prod.center = -1

        UNION ALL

        SELECT 
            longtodate(cc.VALID_UNTIL),
            cc.OWNER_CENTER PERSON_CENTER,
            cc.OWNER_ID PERSON_ID,
            longToDate(inv.TRANS_TIME) LAST_BILLED,
            prod.NAME PRODUCT_NAME,
            invl.TOTAL_AMOUNT,
            cc.CLIPS_LEFT clips_left,
            CASE WHEN inv.TRANS_TIME >= (EXTRACT(EPOCH FROM (current_timestamp - INTERVAL '3 months')) * 1000) 
                 THEN 1 ELSE 0 END AS IN_RANGE
        FROM CLIPCARDS cc
        JOIN INVOICE_LINES_MT invl 
          ON cc.INVOICELINE_CENTER = invl.CENTER 
         AND cc.INVOICELINE_ID     = invl.ID 
         AND cc.INVOICELINE_SUBID  = invl.SUBID
        JOIN INVOICES inv 
          ON inv.CENTER = invl.CENTER 
         AND inv.ID     = invl.ID
        JOIN PRODUCTS prod 
          ON prod.CENTER = invl.PRODUCTCENTER 
         AND prod.ID     = invl.PRODUCTID
        WHERE (prod.CENTER, prod.ID) IN (
            SELECT link.PRODUCT_CENTER, link.PRODUCT_ID
            FROM PRODUCT_AND_PRODUCT_GROUP_LINK link
            JOIN PRODUCT_GROUP pg 
              ON pg.ID = link.PRODUCT_GROUP_ID
             AND (pg.ID in (212,227) OR pg.parent_product_group_id in (212,227))
        )
          AND cc.CANCELLED = 0
    ) i1
    JOIN PERSONS p 
      ON p.CENTER = i1.person_center 
     AND p.id     = i1.person_id
    JOIN CENTERS c 
      ON c.ID = i1.person_center 
     AND c.ID in (:scope)
    LEFT JOIN SUBSCRIPTIONS s 
      ON s.OWNER_CENTER = i1.person_center 
     AND s.OWNER_ID     = i1.person_id 
     AND s.STATE IN (2,3,4,8)
	 AND EXISTS (
     SELECT 1
     FROM SUBSCRIPTION_ADDON sa2
     JOIN MASTERPRODUCTREGISTER mpr2 ON mpr2.ID = sa2.ADDON_PRODUCT_ID
     JOIN PRODUCTS prod2 ON prod2.CENTER = sa2.SUBSCRIPTION_CENTER 
                        AND prod2.GLOBALID = mpr2.GLOBALID
     JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link2 ON link2.PRODUCT_CENTER = prod2.CENTER 
                                              AND link2.PRODUCT_ID = prod2.ID
     JOIN PRODUCT_GROUP pg2 ON pg2.ID = link2.PRODUCT_GROUP_ID
     WHERE sa2.SUBSCRIPTION_CENTER = s.CENTER
       AND sa2.SUBSCRIPTION_ID = s.ID
       AND (pg2.ID = 227 OR pg2.parent_product_group_id = 227)
 )
    JOIN PERSON_EXT_ATTRS email 
      ON email.PERSONCENTER = p.CENTER 
     AND email.PERSONID     = p.ID 
     AND email.NAME = '_eClub_Email'
) i2
LEFT JOIN clip_data cd 
       ON cd.person_center = split_part(i2."Person_ID",'p',1)::int
      AND cd.person_id     = split_part(i2."Person_ID",'p',2)::int
WHERE i2."IN_RANGE" = 1 and cd.total_clips > 0
GROUP BY 
    i2."CLUB",
    i2."CLUB_NAME",
    i2."Person_ID",
    i2."Product bought last purchase",
    i2."Person_STATUS",
    i2."Subscription_State",
    cd.total_clips
ORDER BY 
    i2."Person_ID",
    i2."Product bought last purchase";

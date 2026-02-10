-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     i2."CLUB",
     i2."CLUB_NAME",
     i2."MEMBERSHIP_NUMBER",
     i2."SURNAME",
     i2."FORENAME",
     i2."FIRST_PT_PURCHASE",
     i2."LAST_PT_PURCHASE",
     i2."Product bought last purchase",
     i2."Value OF product purchase",
     i2."Clips LEFT",
         i2.expiry_date
 FROM
     (
         SELECT
             p.EXTERNAL_ID,
             p.CENTER "CLUB",
             c.NAME "CLUB_NAME",
             s.CENTER || 'ss' || s.ID "MEMBERSHIP_NUMBER",
             p.LASTNAME "SURNAME",
             p.FIRSTNAME "FORENAME",
             email.TXTVALUE "EMAIL_ADDRESS",
             FIRST_VALUE(i1.LAST_BILLED) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY i1.LAST_BILLED ASC) "FIRST_PT_PURCHASE",
             FIRST_VALUE(i1.LAST_BILLED) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY i1.LAST_BILLED DESC) "LAST_PT_PURCHASE",
             FIRST_VALUE(i1.PRODUCT_NAME) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY i1.LAST_BILLED DESC) "Product bought last purchase" ,
             FIRST_VALUE(i1.PRICE) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY i1.LAST_BILLED DESC) "Value OF product purchase",
             i1.CLIPS_LEFT "Clips LEFT",
                         i1.expiry_date "expiry_date",
             MAX(i1.IN_RANGE) OVER (PARTITION BY p.EXTERNAL_ID ) "IN_RANGE"
         FROM
             (
                 SELECT
                                         sa.END_DATE expiry_date ,
                     s.OWNER_CENTER PERSON_CENTER,
                     s.OWNER_ID PERSON_ID,
                     add_months(s.BILLED_UNTIL_DATE,-1) LAST_BILLED,
                     prod.NAME PRODUCT_NAME,
                     prod.PRICE,
                     -1 clips_left,
                     CASE
                         WHEN sa.END_DATE IS NULL
                             OR sa.END_DATE > add_months(current_timestamp,-3)
                         THEN 1
                         ELSE 0
                     END AS IN_RANGE
                 FROM
                     SUBSCRIPTION_ADDON sa
                 JOIN MASTERPRODUCTREGISTER mpr
                 ON
                     mpr.ID = sa.ADDON_PRODUCT_ID
                 JOIN PRODUCTS prod
                 ON
                     prod.CENTER = sa.SUBSCRIPTION_CENTER
                     AND prod.GLOBALID = mpr.GLOBALID
                 JOIN SUBSCRIPTIONS s
                 ON
                     s.CENTER = sa.SUBSCRIPTION_CENTER
                     AND s.ID = sa.SUBSCRIPTION_ID
                 WHERE
                     (
                         prod.CENTER,prod.ID
                     )
                     IN
                     (
                         SELECT
                             link.PRODUCT_CENTER,
                             link.PRODUCT_ID
                         FROM
                             PRODUCT_AND_PRODUCT_GROUP_LINK link
                         JOIN PRODUCT_GROUP pg
                         ON
                             pg.ID = link.PRODUCT_GROUP_ID
                             AND (pg.ID = 271 or pg.parent_product_group_id = 271)
                     )
                     AND sa.CANCELLED = 0
                                 /* To kill the first part of the join */
                                         and prod.center = -1
                 UNION ALL
                 SELECT
                                         longtodate(cc.VALID_UNTIL) ,
                     cc.OWNER_CENTER PERSON_CENTER,
                     cc.OWNER_ID PERSON_ID,
                     longToDate(inv.TRANS_TIME) LAST_BILLED,
                     prod.NAME PRODUCT_NAME,
                     invl.TOTAL_AMOUNT,
                     cc.CLIPS_LEFT clips_left,
                     CASE
                         WHEN inv.TRANS_TIME >= dateToLong(TO_CHAR(add_months(current_timestamp,-3),'YYYY-MM-dd HH24:MI'))
                         THEN 1
                         ELSE 0
                     END AS IN_RANGE
                 FROM
                     CLIPCARDS cc
                 JOIN INVOICELINES invl
                 ON
                     cc.INVOICELINE_CENTER = invl.CENTER
                     AND cc.INVOICELINE_ID = invl.ID
                     AND cc.INVOICELINE_SUBID = invl.SUBID
                 JOIN INVOICES inv
                 ON
                     inv.CENTER = invl.CENTER
                     AND inv.ID = invl.ID
                 JOIN PRODUCTS prod
                 ON
                     prod.CENTER = invl.PRODUCTCENTER
                     AND prod.ID = invl.PRODUCTID
                 WHERE
                     --            inv.TRANS_TIME >= dateToLong(TO_CHAR(add_months(sysdate,-3),'YYYY-MM-dd HH24:MI'))
                     (
                         prod.CENTER,prod.ID
                     )
                     IN
                     (
                         SELECT
                             link.PRODUCT_CENTER,
                             link.PRODUCT_ID
                         FROM
                             PRODUCT_AND_PRODUCT_GROUP_LINK link
                         JOIN PRODUCT_GROUP pg
                         ON
                             pg.ID = link.PRODUCT_GROUP_ID
                                                         AND (pg.ID = 271 or pg.parent_product_group_id = 271)
                     )
                                         and cc.CANCELLED = 0
             )
             i1
         JOIN PERSONS p
         ON
             p.CENTER = i1.person_center
             AND p.id = i1.person_id
         JOIN CENTERS c
         ON
             c.ID = i1.person_center
             AND c.ID in (:scope)
         LEFT JOIN SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = i1.person_center
             AND s.OWNER_ID = i1.person_id
             AND s.STATE IN (2,4,8)
         JOIN PERSON_EXT_ATTRS email
         ON
             email.PERSONCENTER = p.CENTER
             AND email.PERSONID = p.ID
             AND email.NAME = '_eClub_Email'
     )
     i2
 WHERE
     i2."IN_RANGE" = 1

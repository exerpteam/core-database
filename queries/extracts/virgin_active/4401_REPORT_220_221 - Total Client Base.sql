 SELECT
     CLUB_ID,
     CLUB_NAME,
     PID,
     PERSON_FIRST_NAME,
     PERSON_LAST_NAME,
     PAYER_ID,
     PAYER_FIRST_NAME,
     PAYER_LAST_NAME,
     LAST_TRANS_AMOUNT,
     LAST_TRANS,
     PREVIOUS_TRANSACTION,
     PRODUCT_NAME,
     PT_TYPE,
     PRIMARY_PRODUCT_GROUP,
     PT_AS_SECONDARY_PRODUCT_GROUP,
     NEW_CUSTOMER
 FROM
     (
         SELECT
             first_value(i2.PREVIOUS_TRANSACTION ) OVER (PARTITION BY i2.pid ORDER BY i2.PREVIOUS_TRANSACTION DESC NULLS LAST) PREVIOUS_TRANSACTION,
             i2.club_ID,
             i2.club_name,
             i2.PID,
             i2.PERSON_FIRST_NAME,
             i2.PERSON_LAST_NAME,
             i2.PAYER_ID,
             i2.PAYER_FIRST_NAME,
             i2.PAYER_LAST_NAME,
             i2.last_trans_amount,
             i2.last_trans,
             i2.PRODUCT_NAME,
             i2.PT_TYPE,
             i2.PRIMARY_PRODUCT_GROUP,
             i2.PT_AS_SECONDARY_PRODUCT_GROUP,
             CASE
                 WHEN first_value(i2.PREVIOUS_TRANSACTION ) OVER (PARTITION BY i2.pid ORDER BY i2.PREVIOUS_TRANSACTION DESC NULLS LAST) IS NULL
                     OR months_between(i2.LAST_TRANS,first_value(i2.PREVIOUS_TRANSACTION::date ) OVER (PARTITION BY i2.pid ORDER BY i2.PREVIOUS_TRANSACTION DESC NULLS LAST)) > $$inactive_period$$
	                 OR TO_CHAR(first_value(i2.PREVIOUS_TRANSACTION ) OVER (PARTITION BY i2.pid ORDER BY i2.PREVIOUS_TRANSACTION DESC NULLS LAST),'YYYY-MM-DD') = TO_CHAR(i2.LAST_TRANS,'YYYY-MM-DD')
                 THEN 'YES'
                 ELSE 'NO'
             END AS new_customer,
             CASE
                 WHEN TO_CHAR(i2.last_trans_day,'YYYY-MM-DD') = TO_CHAR(i2.LAST_TRANS,'YYYY-MM-DD')
                 THEN 'YES'
                 ELSE 'NO'
             END AS keep
         FROM
             (
                 SELECT
                     i1.trans_time,
                     i1.INV_ID,
                     i1.PERSON_CENTER || 'p' || i1.PERSON_ID pid,
                     i1.PERSON_FIRST_NAME,
                     i1.PERSON_LAST_NAME,
                     i1.CLUB_ID,
                     i1.CLUB_NAME,
                     i1.PAYER_ID,
                     i1.PAYER_FIRST_NAME,
                     i1.PAYER_LAST_NAME,
                     i1.INV_TRANS_TIME ,
                     first_value(i1.INV_TRANS_TIME) OVER (PARTITION BY i1.PERSON_CENTER,i1.PERSON_ID ORDER BY i1.INV_TRANS_TIME DESC NULLS LAST) last_trans_day ,
                     i1.INV_TRANS_TIME last_trans ,
                     i1.TOTAL_AMOUNT   last_trans_amount ,
                     MAX(
                         CASE
                             WHEN i1.trans_time > 1
                                 AND i1.INV_TRANS_TIME < i1.max_INV_TRANS_TIME
                             THEN i1.INV_TRANS_TIME
                             ELSE NULL
                         END) AS previous_transaction,
                     max_INV_TRANS_TIME,
                     i1.PRODUCT_NAME,
                     i1.PT_TYPE ,
                     i1.PRIMARY_PRODUCT_GROUP ,
                     i1.PT_AS_SECONDARY_PRODUCT_GROUP
                 FROM
                     (
                         SELECT DISTINCT
                             payer.FIRSTNAME               PAYER_FIRST_NAME,
                             payer.LASTNAME                PAYER_LAST_NAME,
                             person.FIRSTNAME              PERSON_FIRST_NAME,
                             person.LASTNAME               PERSON_LAST_NAME,
                             inv.CENTER || 'inv' || inv.id inv_id,
                             invl.SUBID,
                             c.id        CLUB_ID,
                             c.SHORTNAME CLUB_NAME,
                             invl.PERSON_CENTER,
                             invl.PERSON_ID ,
                             invl.TOTAL_AMOUNT,
                             inv.PAYER_CENTER || 'p' || inv.PAYER_ID                                                                                  payer_id,
                             longToDate(inv.TRANS_TIME)                                                                                       INV_TRANS_TIME,
                             FIRST_VALUE(longToDate(inv.TRANS_TIME)) OVER (PARTITION BY PERSON_CENTER,PERSON_ID ORDER BY inv.TRANS_TIME DESC) max_INV_TRANS_TIME,
                             inv.TRANS_TIME,
                             pgr.NAME                                                                                                                                                                                                        PRIMARY_PRODUCT_GROUP,
                             prod.NAME                                                                                                                                                                                                        PRODUCT_NAME,
                             CASE PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription'  WHEN 13 THEN  'Subscription add-on' END PT_TYPE,
                             CASE WHEN spg.ID IS NOT NULL THEN 'YES' ELSE 'NO' END                                                                                                                                                                                                        PT_AS_SECONDARY_PRODUCT_GROUP
                         FROM
                             INVOICELINES invl
                         JOIN
                             INVOICES inv
                         ON
                             inv.CENTER = invl.CENTER
                             AND inv.ID = invl.ID
                         JOIN
                             PERSONS payer
                         ON
                             payer.CENTER = inv.PAYER_CENTER
                             AND payer.id = inv.PAYER_ID
                         JOIN
                             PERSONS person
                         ON
                             person.CENTER = invl.PERSON_CENTER
                             AND person.id = invl.PERSON_ID
                         JOIN
                             CENTERS c
                         ON
                             c.ID = inv.CENTER
                         JOIN
                             PRODUCTS prod
                         ON
                             prod.CENTER = invl.PRODUCTCENTER
                             AND prod.ID = invl.PRODUCTID
                         JOIN
                             PRODUCT_GROUP pgr
                         ON
                             pgr.ID = prod.PRIMARY_PRODUCT_GROUP_ID
                         LEFT JOIN
                             PRODUCT_AND_PRODUCT_GROUP_LINK link
                         ON
                             link.PRODUCT_CENTER = prod.CENTER
                             AND link.PRODUCT_ID = prod.ID
                         LEFT JOIN
                             PRODUCT_GROUP spg
                         ON
                             spg.ID = link.PRODUCT_GROUP_ID
                             AND (
                                 spg.ID = 271
                                 OR spg.parent_product_group_id = 271)
                         WHERE
                             prod.PTYPE IN (4,10,12,13)
                             AND ((
                                     $$onlyPT$$ = 'YES'
                                     AND spg.ID IS NOT NULL)
                                 OR $$onlyPT$$ = 'NO')
                             AND invl.PERSON_CENTER IN ($$scope$$)
                             ) i1
                 GROUP BY
                     i1.trans_time,
                     i1.INV_ID,
                     i1.PERSON_CENTER ,
                     i1.PERSON_ID ,
                     i1.PERSON_FIRST_NAME,
                     i1.PERSON_LAST_NAME,
                     i1.CLUB_ID,
                     i1.CLUB_NAME,
                     max_INV_TRANS_TIME,
                     i1.PAYER_ID,
                     i1.PAYER_FIRST_NAME,
                     i1.PAYER_LAST_NAME,
                     i1.INV_TRANS_TIME,
                     i1.TOTAL_AMOUNT,
                     i1.PRODUCT_NAME,
                     i1.PT_TYPE ,
                     i1.PRIMARY_PRODUCT_GROUP ,
                     i1.PT_AS_SECONDARY_PRODUCT_GROUP )i2 ) i3
 WHERE
     i3.keep = 'YES'

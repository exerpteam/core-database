 SELECT
         c.id,
         c.name center_name,
     ss.SALES_DATE,
     ss.START_DATE,
 ss.CANCELLATION_DATE,
 case ss.TYPE  when 1 then  'New'  when 2 then  'Extension'  when 3 then  'Change'  else 'Unknown' end sales_type,
     prod.NAME product_name,
     p.CENTER || 'p' || p.ID pid,
    /* a.NAME area,*/
     pg.NAME product_group_name,
     CASE
         WHEN CASE WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 1 ELSE 0 END = 1
         THEN -1 * COUNT(pg.ID) OVER (PARTITION BY pg.ID,CASE WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 1 ELSE 0 END )
         ELSE COUNT(pg.ID) OVER (PARTITION BY pg.ID,CASE WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 1 ELSE 0 END )
     END AS total_sales_within,
 perCreation.txtvalue "Original joined date",
 oldSystemId.txtvalue "Old System Date"
 FROM
     SUBSCRIPTION_SALES ss
 JOIN PERSONS pold
 ON
     pold.CENTER = ss.OWNER_CENTER
     AND pold.ID = ss.OWNER_ID
 JOIN PERSONS p
 ON
     p.CENTER = pold.CURRENT_PERSON_CENTER
     AND p.ID = pold.CURRENT_PERSON_ID
 join centers c on c.id = p.center
 /*
 JOIN AREA_CENTERS ac
 ON
     ac.CENTER = p.CENTER
 JOIN AREAS a
 ON
     a.ID = ac.AREA
 */
 JOIN PRODUCTS prod
 ON
     prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
     AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
 JOIN PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
     AND pg.NAME LIKE 'Mem Cat%'
 LEFT JOIN PERSON_EXT_ATTRS perCreation
 ON
     perCreation.PERSONCENTER = p.CENTER
     AND perCreation.PERSONID = p.ID
     AND perCreation.NAME = 'CREATION_DATE'
 LEFT JOIN PERSON_EXT_ATTRS oldSystemId
 ON
     oldSystemId.PERSONCENTER = p.CENTER
     AND oldSystemId.PERSONID = p.ID
     AND oldSystemId.NAME = '_eClub_OldSystemPersonId'
 WHERE
     ss.owner_center IN (:scope)
     AND
     (
         (
             ss.CANCELLATION_DATE IS NULL
             AND ss.SALES_DATE BETWEEN :saleStart AND
             (
                 :saleEnd + 1
             )
         )
         OR
         (
             ss.CANCELLATION_DATE IS NOT NULL
             AND ss.CANCELLATION_DATE BETWEEN :saleStart AND
             (
                 :saleEnd + 1
             )
         )
     )

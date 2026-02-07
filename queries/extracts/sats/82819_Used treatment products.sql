 SELECT
     a.person_center ||'p'|| a.person_id as "member ID",
     prod.name as "Product name",
     count(a.id) as "Clip used ",
     longtodate(a.START_TIME)  as "Clip used date",
     c.name as "Clip used center"
 FROM
      attends a
 JOIN booking_resources b
     ON
       a.booking_resource_center = b.center
       and a.booking_resource_id = b.id
 join persons p
     on
       a.person_center= p.center
       and a.person_id =p.id
 join PRIVILEGE_USAGES pu
     on pu.TARGET_SERVICE = 'Attend'
      and pu.TARGET_CENTER = a.CENTER
      and pu.TARGET_ID = a.id
      and pu.STATE = 'USED'
 join clipcards clip
     on
       clip.CENTER = pu.SOURCE_CENTER
       and clip.ID = pu.SOURCE_ID
       and clip.SUBID = pu.SOURCE_SUBID
 join invoicelines il
     on
       clip.invoiceline_center = il.center
       and clip.invoiceline_id = il.id
       and clip.invoiceline_subid = il.subid
 join products prod
     on
        il.productcenter = prod.center
        and il.productid = prod.id
 Join PRODUCT_AND_PRODUCT_GROUP_LINK ppl
 on prod.center = ppl.product_center
 and
 prod.id = ppl.product_id
 join
 PRODUCT_GROUP pg
 on
 ppl.PRODUCT_GROUP_ID = pg.id
 join PRIVILEGE_GRANTS pgs on pgs.GRANTER_SERVICE = 'GlobalCard' and pgs.ID = pu.GRANT_ID
 join centers c
 on a.center = c.id
 WHERE
    a.center in (:scope)
   -- c.COUNTRY = 'NO'
   --  and b.name in('Treatment - Physio')
     and a.START_TIME BETWEEN
     :fromTime
     AND
     :toTime
   and pg.id in (43602)
 Group by
  a.person_center,
  a.person_id,
  prod.name,
  a.START_TIME,
  a.id,
  c.name
 order by
  a.person_center,
  a.person_id

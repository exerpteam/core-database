 SELECT
     a.booking_resource_center as Center,
     b.center,
     b.name,
     a.person_center,
     a.person_id,
     longtodate(a.START_TIME)  as AttendTime,
     floor(months_between(current_timestamp, p.BIRTHDATE) / 12) as age,
     p.sex,
     clip.clips_left,
     il.total_amount,
     prod.globalid,
     prod.name
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
 join PRIVILEGE_GRANTS pg on pg.GRANTER_SERVICE = 'GlobalCard' and pg.ID = pu.GRANT_ID
 WHERE
     a.center in (:scope)
     and b.name in('Massage', 'Massage25')
     and a.START_TIME BETWEEN
     :fromTime
     AND
     :toTime
     and prod.globalid like '%MASSAGE%'
 order by
     p.center,
     p.id

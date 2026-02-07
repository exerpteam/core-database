 select
         P.CENTER||'p'||P.ID as CUSTOMER_ID,
         P.FIRSTNAME||' '||P.LASTNAME as CUSTOMER,
         pr.globalID as clipcard,
         pr.name as product_name,
 --  to_char(longtodate(ccu.time), 'YYYY-MM-dd HH24:MI') as clip_used,
         longtodate(ccu.time) as clip_used_at,
         c.clips_left,
         longtodate(c.valid_until) as valid_until
 FROM
      pulse.clipcards c
 join pulse.PERSONS P
   on C.OWNER_CENTER=P.CENTER
      and C.OWNER_ID=P.ID
 join pulse.card_clip_usages ccu
   on c.center = ccu.card_center
      and c.id = ccu.card_id
      and c.subid = ccu.card_subid
 join pulse.PRODUCTS pr
   on c.center = pr.CENTER
      and c.id = pr.ID
 --join pulse.product_group pg
 --  on
   --   pr.primary_product_group_id = pg.id
 WHERE
  --    pg.name in ('Clip card')
       ccu.time >= :date_from
      and ccu.time <= :date_to+1
      and ccu.type not in ('ADJUSTMENT', 'TRANSFER')
          and c.owner_center in (:scope)
 order by
     P.CENTER||'p'||P.ID,
     ccu.time

SELECT
       
        pr.NAME,
      count(pr.name) as "number"
  
FROM
    persons per
JOIN sats.participations par
ON
    per.center = par.participant_center
AND per.id = par.participant_id
JOIN sats.bookings bo
ON
    par.booking_center = bo.center
AND par.booking_id = bo.id
JOIN sats.activity an
ON
    bo.activity = an.id
join sats.privilege_usages pu
    on
        par.CENTER = pu.TARGET_CENTER
    AND par.ID = pu.TARGET_ID
    AND pu.TARGET_SERVICE = 'Participation'
JOIN PRIVILEGE_GRANTS pg
    ON
        pg.ID = pu.GRANT_ID
    and pg.GRANTER_SERVICE like 'GlobalCard'
join PERSON_EXT_ATTRS ext
on
per.center = ext.PERSONCENTER
and
per.id = ext.PERSONID
and ext.name = 'UNBROKENMEMBERSHIPGROUPALL'
    
left JOIN sats.privilege_sets ps
    ON
    pg.PRIVILEGE_SET = ps.id
left join sats.clipcards clip
    on
    pu.source_center = clip.center
    and pu.source_id = clip.id
    and pu.source_subid = clip.subid
left join sats.invoicelines il
    on
    clip.INVOICELINE_CENTER    = il.center
    and clip.INVOICELINE_ID    = il.id
    and clip.INVOICELINE_SUBID = il.subid
left join sats.PRODUCTS pr
    on
    clip.CENTER = pr.CENTER
    and clip.ID = pr.ID  
    
WHERE
    par.state = 'PARTICIPATION'
    AND longtodate(par.start_time) >= (:date_from)
    AND longtodate(par.start_time) <= (:date_to) + 1
    and per.center in (:scope)
    and pr.name in ('GX & concept access – Loyalty Platinum','GX & concept access – Loyalty Blue','GX & concept access – Loyalty Gold','GX & concept access – Loyalty Silver')
 
group by
ext.txtvalue,
pr.name




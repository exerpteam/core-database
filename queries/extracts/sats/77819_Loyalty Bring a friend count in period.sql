 WITH
     params AS materialized
     (
         SELECT
             c.id,
             cast(datetolongC(TO_CHAR(cast(:FromDate as date), 'YYYY-MM-dd HH24:MI'), c.id) as bigint)                AS FromDate,
             cast(datetolongC(TO_CHAR(cast(:ToDate as date), 'YYYY-MM-dd HH24:MI'), c.id)  as bigint) + (24*60*60*1000)-1 AS ToDate
         FROM
             centers c
         WHERE
             c.id IN (:center)
 )
 SELECT
     ps.name,
     ext.txtvalue as "Loyalty level",
     count(ps.name) as "Count"
 from
          attends a
     join persons p
       on a.person_center = p.center
      and a.person_id = p.id
 join BOOKING_RESOURCES br
 on
 a.BOOKING_RESOURCE_CENTER = br.center
 and
 a.BOOKING_RESOURCE_ID = br.id
 and br.name = 'Bring a friend'
 cross join params
 JOIN
             PRIVILEGE_USAGES pu
         ON
             pu.TARGET_SERVICE = 'Attend'
             AND pu.TARGET_CENTER = a.center
             AND pu.TARGET_ID = a.id
             and pu.target_start_time >= params.FromDate and pu.target_start_time <= params.ToDate
 JOIN PRIVILEGE_GRANTS pg
     ON
         pg.ID = pu.GRANT_ID
 JOIN privilege_sets ps
     ON
     pg.PRIVILEGE_SET = ps.id
     and ps.name = 'Loyalty program – Bring a friend'
 join person_ext_attrs ext
 on
 p.center = ext.PERSONCENTER
 and
 p.id = ext.PERSONID
 and ext.name = 'UNBROKENMEMBERSHIPGROUPALL'
 where
      a.start_time >= params.FromDate
     and a.start_time <= params.ToDate
     and a.person_center in (:center)
     and ext.txtvalue = (:loyaltylevel)
 group by
 ps.name,
 ext.txtvalue

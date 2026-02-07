SELECT
     results.centername as "Club name",
     results.PERSONKEY AS "Member ID",
     results.fullname as "Member Name",
     results.age as "Age",
     results.sex as "Gender",
     results.prodname as "Sub Type",
     results.subscription_price as "Monthly Price (current)",
     results.start_date as "Subscription start Date",
     
     results.end_date as "Subscription end Date",
     results.first_active_start_date as "Join Date",
     results.COUNT_ACTIVE_DAYS as "Length of Membership",
     results.PERSON_STATUS as "Person Status",
     results.SUBSCRIPTION_STATE as "Subscription status",
     results.SUBSCRIPTION_SUB_STATE as "Subscription sub-status",
     results.txtvalue as "Extended Attribute (VillageAdvance)",
     results.checkin_time2 as "First Visit",
     results.checkin_time as "Last Visit",     
     results.TOTAL_CHECKINS as "Total Visits", 
     results.txtvalue2 as "Opt in Email",
     results.txtvalue3 as "Opt in SMS",
     results.je7date as "Note Header re 7 Day",
     results.je30date as "Note Header re 30 Day",
     results.CLASS_START_TIME as "Activity Date - start time",
     results.LOCAL_ACTIVITY_NAME as "Activity Name",
     results.ACTIVITY_GROUP_NAME as "Activity Group"
     
     
     
     
     
 FROM
     (
         SELECT
                 innersql.CENTER ,
     innersql.ID ,
     innersql.PERSONKEY,
     innersql.fullname,
     innersql.age,
     innersql.sex,
     innersql.prodname,
     innersql.first_active_start_date,
     innersql.COUNT_ACTIVE_DAYS,
     count(*) AS TOTAL_CHECKINS,
     innersql.txtvalue,
     innersql.centername,
     innersql.txtvalue2,
     innersql.txtvalue3,
     innersql.je7date,
     innersql.je30date,
     innersql.CLASS_START_TIME,
     innersql.LOCAL_ACTIVITY_NAME,
     innersql.ACTIVITY_GROUP_NAME,
     innersql.checkin_time,
     innersql.checkin_time2,
     innersql.PERSON_STATUS,
     innersql.SUBSCRIPTION_STATE,
     innersql.end_date,
     innersql.subscription_price,
     innersql.start_date,
     innersql.SUBSCRIPTION_SUB_STATE
            
         FROM
                 (
                 SELECT DISTINCT
                     p.CENTER ,
                     p.ID ,
                     p.CENTER||'p'||p.ID as PERSONKEY,
                     p.FIRSTNAME,
                     p.LASTNAME,
                     p.fullname,
                     CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
                     CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
                     extract(year from age(p.BIRTHDATE)) as age,
                     p.sex,
                     prod.name as prodname,
                     p.first_active_start_date,
                     COALESCE(ext.TXTVALUE,'NONE') as current_group,
                     TRUNC(CURRENT_TIMESTAMP) - p.LAST_ACTIVE_START_DATE + 1 AS COUNT_ACTIVE_DAYS,
                     ext.txtvalue,
                     ext2.txtvalue as txtvalue2,
                     ext3.txtvalue as txtvalue3,
                     pt.center as ptcenter,
                     pt.id as ptid,
                     c.name as centername,
                     longtodate(je30.creation_time) as je30date,
                     longtodate(je7.creation_time) as je7date,
                     longToDate(bo.STARTTIME)                        AS CLASS_START_TIME,
                     bo.name                                         AS LOCAL_ACTIVITY_NAME,
                     actg.name                                       AS ACTIVITY_GROUP_NAME,
                     statuses.checkin_time,
                     statuses2.checkin_time as checkin_time2,
                     s.end_date,
                     s.start_date,
                     CASE s.SUB_STATE WHEN 1 THEN 'NEW' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE,
                     s.subscription_price
                     
                   
                     
                     
                 FROM
                     PERSONS p
                                 join
                 persons pt
                 ON
                                 pt.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
                                 AND pt.TRANSFERS_CURRENT_PRS_ID = p.ID
                                 
                                 
                 JOIN 
                     CENTERS c
                 ON
                     c.ID = p.CENTER 
                 left join subscriptions s
                 on
                 s.owner_center = p.center
                 and 
                 s.owner_id = p.id
                 and s.state in (2,4)
                 left JOIN SubscriptionTypes st
                 ON 
                 s.SubscriptionType_Center =  st.Center
                 AND  S.SubscriptionType_ID=  St.ID
 
                 left JOIN Products prod
                 ON st.Center = prod.Center AND  st.Id = Prod.Id    
                     
                 LEFT JOIN
                     PERSON_EXT_ATTRS ext
                 ON
                     ext.PERSONCENTER = p.CENTER
                     AND ext.PERSONID = p.ID
                     AND ext.NAME = 'VillageAdvance'
                      LEFT JOIN
                     PERSON_EXT_ATTRS ext2
                 ON
                     ext2.PERSONCENTER = p.CENTER
                     AND ext2.PERSONID = p.ID
                     AND ext2.NAME = '_eClub_AllowedChannelEmail'
                     LEFT JOIN
                     PERSON_EXT_ATTRS ext3
                 ON
                     ext3.PERSONCENTER = p.CENTER
                     AND ext3.PERSONID = p.ID
                     AND ext3.NAME = '_eClub_AllowedChannelSMS'
                     /*LEFT JOIN
                     PERSON_EXT_ATTRS ext3
                 ON
                     ext3.PERSONCENTER = p.CENTER
                     AND ext3.PERSONID = p.ID
                     AND ext3.NAME = '_eClub_AllowedChannelSMS'*/
                      left join journalentries je7
                     on
                     je7.person_center = p.center
                     and
                     je7.person_id = p.id
                     and je7.name =  'LCM 7 DAY NEW MEMBER CALL'                    
                     
                     left join journalentries je30
                     on
                     je30.person_center = p.center
                     and
                     je30.person_id = p.id
                     and je30.name =  '30 DAY NEW MEMBER CALL'
         left JOIN
     participations par
 ON
     par.PARTICIPANT_CENTER = p.CENTER
 AND par.PARTICIPANT_ID = p.id
 and par.state = 'PARTICIPATION'
 left JOIN
     bookings bo
 ON
     par.BOOKING_ID = bo.ID
 AND par.BOOKING_CENTER = bo.CENTER
 left JOIN
     ACTIVITY act
 ON
     bo.ACTIVITY = act.id
 left JOIN
     ACTIVITY_GROUP actg
 ON
     act.ACTIVITY_GROUP_ID = actg.id    
left join
(

Select
ranking.checkin_time,
ranking.person_center,
ranking.person_id

from
(
select
rank() over(partition by ch2.PERSON_ID, ch2.PERSON_CENTER ORDER BY ch2.checkin_time  DESC) as rnk,
ch2.person_center,
ch2.person_id,

longtodate(ch2.checkin_time) as checkin_time           

from persons p2
join subscriptions s2
on
p2.center = s2.owner_center
and
p2.id = s2.owner_id

join checkins ch2
                  ON
                         ch2.person_center = p2.center
                         AND ch2.person_id = p2.id
                         and ch2.CHECKIN_RESULT < 3     
where ch2.person_center in (:center) 
and ch2.CHECKIN_RESULT < 3  
and s2.start_date >= (:datefrom)
and s2.start_date <= (:dateto)                        
                         
  ) ranking                    
 
 where rnk = 1  

 )STATUSES 
 
 on             
STATUSES.person_center = pt.center
and STATUSES.person_id   = pt.id     

left join
(   
Select
ranking2.checkin_time,
ranking2.person_center,
ranking2.person_id


from
(
select
rank() over(partition by ch3.PERSON_ID, ch3.PERSON_CENTER ORDER BY ch3.checkin_time  ASC) as rnk2,
ch3.person_center,
ch3.person_id,

longtodate(ch3.checkin_time) as checkin_time           

from persons p3
join subscriptions s3
on
p3.center = s3.owner_center
and
p3.id = s3.owner_id

join checkins ch3
                  ON
                         ch3.person_center = p3.center
                         AND ch3.person_id = p3.id
                      and ch3.CHECKIN_RESULT < 3     
where ch3.person_center in (:center) 
and ch3.CHECKIN_RESULT < 3  
and s3.start_date >= (:datefrom)
and s3.start_date <= (:dateto)
and s3.start_date <= longtodate(ch3.checkin_time)
                     
                         
  ) ranking2
  
where rnk2 = 1 
  
)STATUSES2 
 
 on             
STATUSES2.person_center = pt.center
and STATUSES2.person_id   = pt.id                        
 
                      
                     
                 WHERE
           p.center in (:center)
        
                     AND
         
                     p.status IN (0,1,2,3)
                  and s.start_date >= (:datefrom)
                  and s.start_date <= (:dateto)
                  
                        
                      ) innersql
           LEFT JOIN
                         checkins ch
                  ON
                         ch.person_center = innersql.ptcenter
                         AND ch.person_id = innersql.ptid
                         and ch.CHECKIN_RESULT < 3     
                         and ch.CHECKIN_TIME > DATETOLONGC(TO_CHAR(CURRENT_TIMESTAMP - COALESCE(innersql.COUNT_ACTIVE_DAYS,0),'YYYY-MM-DD HH24:MI'), ch.CHECKIN_CENTER)
                   
                         
                        GROUP BY 
                         innersql.CENTER,
                         innersql.ID,
                         innersql.PERSONKEY,
                         innersql.FIRSTNAME,
                         innersql.LASTNAME,
                         innersql.CURRENT_GROUP,
                         innersql.COUNT_ACTIVE_DAYS,
                         innersql.centername,
                         innersql.fullname,
                         innersql.age,
                         innersql.sex,
                         innersql.prodname,
                         innersql.first_active_start_date,
                         innersql.txtvalue,
                         innersql.txtvalue2,
                         innersql.txtvalue3,
                         innersql.je30date,
                         innersql.je7date,
                         innersql.CLASS_START_TIME,
                         innersql.LOCAL_ACTIVITY_NAME,
                         innersql.ACTIVITY_GROUP_NAME,
                         innersql.checkin_time,
                         innersql.PERSON_STATUS,
                         innersql.SUBSCRIPTION_STATE,
                         innersql.end_date,
                         innersql.subscription_price,
                         innersql.checkin_time2,
                         innersql.start_date,
                         innersql.SUBSCRIPTION_SUB_STATE
                         
           ) results
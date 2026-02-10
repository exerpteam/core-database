-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate,
            ($$EndDate$$ + 86400 * 1000) - 1   AS ToDate
        FROM
            dual
    )
SELECT classdate                                                        as "Class Date",
       classtime                                                        as "Class Time",
       name                                                             as "Class Type",
       CLASS_CAPACITY                                                   as "Available Seats",
       total_attend + total_absent                                      as "Total Booked",
       total_attend                                                     as "Total Attend",
       total_absent                                                     as "Total Absent", 
       ROUND(((total_attend+total_absent)/CLASS_CAPACITY)*100, 2)       as "Booked Ratio %", 
       ROUND(total_attend/NULLIF((total_attend + total_absent),0)*100, 2)         as "Show Ration %",
       ROUND((total_attend/CLASS_CAPACITY)*100, 2)                      as "Attend Ratio %" ,
       ROUND((total_absent/NULLIF((total_attend+total_absent),0))*100, 2)         as "Absent Ratio %",
       total_attend_clips                                               as "Attend Clips Used",
       total_absent_clips                                               as "Absent Clips Used", 
       total_attend_clips + total_absent_clips                          as "Total Clips Used",
       ROUND((total_absent_clips/NULLIF(total_absent,0))*100, 2)        as "Absent Clips Charge Ratio %",    
       ROUND(total_attend_revenue, 2)                                   as "Attend Clip Revenue",
       ROUND(total_absent_revenue, 2)                                   as "Absent Clip Revenue",  
       ROUND(total_attend_revenue+total_absent_revenue, 2)              as "Total Revenue",
       ROUND(total_attend_revenue/NULLIF(total_attend,0), 2)            as "Yield per attend"                                          
FROM
(    
SELECT 
    class.classdate, 
    class.classtime,
    class.name,
    class.CLASS_CAPACITY,
    SUM(CASE
           WHEN class.state = 'PARTICIPATION' THEN 
              1
           ELSE 
              0
        END )AS total_attend,
    SUM( CASE
           WHEN class.state = 'CANCELLED' THEN 
             1
           ELSE 
             0
        END)AS total_absent,
    SUM(CASE
           WHEN class.state = 'PARTICIPATION' THEN 
              class.clips*-1
           ELSE 
              0
        END )AS total_attend_clips,
    SUM( CASE
           WHEN class.state = 'CANCELLED' THEN 
             class.clips*-1
           ELSE 
             0
        END)AS total_absent_clips,
    SUM(CASE
           WHEN class.state = 'PARTICIPATION' THEN 
              class.amount/clips_initial
           ELSE 
              0
        END )AS total_attend_revenue,
    SUM( CASE
           WHEN class.state = 'CANCELLED' THEN 
             class.amount/clips_initial
           ELSE 
             0
        END)AS total_absent_revenue                
FROM    
(    
  SELECT
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'yyyy-MM-dd') classdate  ,
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'HH24:MI')    classtime,
    bo.NAME,
    GREATEST(bo.CLASS_CAPACITY, NVL(brc.maximum_participations, bo.CLASS_CAPACITY)) as CLASS_CAPACITY,                                                                
    pa.state,
    ccu.clips,
    cc.clips_initial,
    act.amount
  FROM
    BOOKINGS bo
  JOIN
    BOOKING_RESOURCE_USAGE bru
  ON
    bru.BOOKING_ID = bo.ID
    AND bru.BOOKING_CENTER = bo.CENTER
  JOIN
    BOOKING_RESOURCES br
  ON
    br.CENTER = bru.BOOKING_RESOURCE_CENTER
    AND br.ID = bru.BOOKING_RESOURCE_ID
  JOIN
    BOOKING_RESOURCE_CONFIGS brc
  ON
    brc.BOOKING_RESOURCE_CENTER = br.CENTER
    AND brc.BOOKING_RESOURCE_ID = br.ID    
  CROSS JOIN
    params    
  JOIN
    ACTIVITY ac
  ON
    ac.ID = bo.ACTIVITY
  JOIN
    ACTIVITY_GROUP ag
  ON
    ag.ID = ac.activity_group_id
  JOIN      
    participations pa
  ON  
    (pa.state =  'PARTICIPATION' or (pa.state = 'CANCELLED' AND  pa.cancelation_reason = 'NO_SHOW'))
    AND pa.booking_center = bo.center
    AND pa.booking_id = bo.id
  JOIN
    persons p
  ON
    p.id = pa.participant_id
    AND p.center = pa.participant_center
  JOIN
    puregym.privilege_usages pu
  ON      	
    pu.target_service = 'Participation'
    AND pu.target_center = pa.center
    AND pu.target_id = pa.id
  LEFT JOIN
    puregym.privilege_grants pg
  ON 
    pg.id = pu.grant_id       
    AND pg.granter_service = 'GlobalCard'
  LEFT JOIN 
    puregym.card_clip_usages ccu
  ON
    ccu.id = pu.deduction_key
  LEFT JOIN 
    puregym.clipcards cc
  ON
    cc.center = ccu.card_center
    AND cc.id = ccu.card_id
    AND cc.subid = ccu.card_subid
  LEFT JOIN 
    puregym.invoicelines il
  ON 
    il.center = cc.invoiceline_center
    AND il.id = cc.invoiceline_id
    AND il.subid = cc.invoiceline_subid
  LEFT JOIN
    puregym.account_trans act
  ON 
    act.center = il.account_trans_center
    AND act.id = il.account_trans_id
    AND act.subid = il.account_trans_subid  
  WHERE
    bo.CENTER IN ($$Scope$$)
    AND bo.STARTTIME>= params.FromDate
    AND bo.STARTTIME<= params.ToDate
    AND p.sex in ($$Sex$$)
    AND bo.STATE='ACTIVE'
    AND ag.name = 'Pure Ride Classes'
)class
group by class.classdate, 
         class.classtime, 
         class.name,
         class.CLASS_CAPACITY
)
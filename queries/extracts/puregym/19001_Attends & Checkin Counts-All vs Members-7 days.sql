WITH 
  v0 AS
  (
    SELECT  /*+ materialized */
            attends.center center
          , centers.name center_name
          , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')  access_date        
          , nvl(booking_resources.coment, 'NEITHER') resource_cat
          , decode(stateid, 2, 'Y', 'N') is_member
          , count(1) cat_count           
      FROM  attends  
        JOIN centers
          ON attends.center = centers.id                   
        JOIN booking_resources
          ON attends.booking_resource_center = booking_resources.center
         AND attends.booking_resource_id = booking_resources.id  
        JOIN state_change_log
          ON attends.person_center = state_change_log.center
         AND attends.person_id = state_change_log.id
         AND state_change_log.entry_type = 5                  
         AND attends.start_time between state_change_log.entry_start_time and nvl(state_change_log.entry_end_time, attends.start_time)
        JOIN persons
          ON persons.center = state_change_log.center
         AND persons.id = state_change_log.id         
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$
        AND attends.start_time < $$startdate$$ + 604800 * 1000        
        AND attends.center IN ($$scope$$) 
    GROUP BY attends.center
           , centers.name
           , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD') 
           , nvl(booking_resources.coment, 'NEITHER')
           , decode(stateid, 2, 'Y', 'N')
  ) 
, v1 as
  (
    SELECT   /*+ opt_param('_OPTIM_PEEK_USER_BINDS ',FALSE) */ 
            attends.center center
          , centers.name center_name
          , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')  access_date 
          , decode(stateid, 2, 'Y', 'N') is_member 
          , count(distinct attends.person_center || 'p' || attends.person_id) unique_attends 
          , count(distinct to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD HH24') || attends.person_center || 'p' || attends.person_id) hourly_unique_attends
      FROM  attends
        JOIN centers
          ON attends.center = centers.id                  
        JOIN booking_resources
          ON attends.booking_resource_center = booking_resources.center
         AND attends.booking_resource_id = booking_resources.id  
         AND NVL(booking_resources.coment, 'NEITHER') IN ('IN', 'DISABLED')  
        JOIN state_change_log
          ON attends.person_center = state_change_log.center
         AND attends.person_id = state_change_log.id
         AND state_change_log.entry_type = 5                  
         AND attends.start_time between state_change_log.entry_start_time and nvl(state_change_log.entry_end_time, attends.start_time)
        JOIN persons
          ON persons.center = state_change_log.center
         AND persons.id = state_change_log.id                     
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$
        AND attends.start_time < $$startdate$$ + 604800 * 1000           
        AND attends.center IN ($$scope$$) 
    GROUP BY attends.center
           , centers.name
           , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')
           , decode(stateid, 2, 'Y', 'N')      
  )
, v2 as  
  (
     SELECT  /*+ opt_param('_OPTIM_PEEK_USER_BINDS ',FALSE) */ 
         * 
     FROM
         (SELECT center
               , center_name
               , access_date
               , resource_cat
               , cat_count
            FROM v0)
          PIVOT
              (SUM(nvl(cat_count, 0)) 
               FOR resource_cat IN ('IN' AS ATTENDS_IN, 'OUT' AS ATTENDS_OUT, 'DISABLED' AS ATTENDS_DISABLED, 'NEITHER' AS ATTENDS_OTHERS))   
  )    
, v2_mem as  
  (
     SELECT  /*+ opt_param('_OPTIM_PEEK_USER_BINDS ',FALSE) */ 
         * 
     FROM
         (SELECT center
               , center_name
               , access_date
               , resource_cat
               , cat_count
            FROM v0
            WHERE is_member = 'Y')
          PIVOT
              (MAX(nvl(cat_count, 0)) 
               FOR resource_cat IN ('IN' AS ATTENDS_IN_MEM, 'OUT' AS ATTENDS_OUT_MEM, 'DISABLED' AS ATTENDS_DISABLED_MEM, 'NEITHER' AS ATTENDS_OTHERS_MEM))   
  )
, v3 as
  (
     SELECT center
          , center_name
          , access_date
          , SUM(nvl(unique_attends,0)) unique_attends
          , SUM(nvl(hourly_unique_attends,0)) hourly_unique_attends
       FROM v1
     GROUP BY 
            center
          , center_name
          , access_date
  )
, v3_mem as
  (
     SELECT center
          , center_name
          , access_date
          , SUM(nvl(unique_attends,0)) unique_attends_mem
          , SUM(nvl(hourly_unique_attends,0)) hourly_unique_attends_mem
       FROM v1
     WHERE is_member = 'Y'
     GROUP BY 
            center
          , center_name
          , access_date
  )
, v4 as  
  (
    SELECT   /*+ materialized */ 
            checkins.checkin_center center
          , centers.name center_name
          , to_char(longtodateTZ(checkins.checkin_time,'Europe/London') , 'YYYY-MM-DD') access_date    
          , count(1) checkins
          , count(distinct checkins.person_center || 'p' || checkins.person_id) unique_checkins          
      FROM  checkins
        JOIN centers
          ON checkins.checkin_center = centers.id         
      WHERE checkins.checkin_time >= $$startdate$$
        AND  checkins.checkin_time < $$startdate$$ + 604800 * 1000      
        AND checkins.checkin_center in ($$scope$$)
    GROUP BY checkins.checkin_center
           , centers.name
           , to_char(longtodateTZ(checkins.checkin_time,'Europe/London') , 'YYYY-MM-DD')               
  ) 
SELECT  nvl(v2.center, v4.center) center
      , nvl(v2.center_name, v4.center_name) center_name
      , nvl(v2.access_date, v4.access_date) access_date
      , v2.attends_in
      , v2.attends_out
      , v2.attends_disabled
      , v2.attends_others
      , v2_mem.attends_in_mem
      , v2_mem.attends_out_mem
      , v2_mem.attends_disabled_mem
      , v2_mem.attends_others_mem      
      , v3.unique_attends
      , v3.hourly_unique_attends
      , v3_mem.unique_attends_mem
      , v3_mem.hourly_unique_attends_mem      
      , v4.checkins
      , v4.unique_checkins
 FROM v2 
   FULL JOIN v2_mem
          ON v2.center = v2_mem.center
         AND v2.access_date = v2_mem.access_date 
   FULL JOIN v3
          ON v2.center = v3.center
         AND v2.access_date = v3.access_date
   FULL JOIN v3_mem
          ON v2.center = v3_mem.center
         AND v2.access_date = v3_mem.access_date
   FULL JOIN v4
          ON v2.center = v4.center
         AND v2.access_date = v4.access_date  
ORDER BY 3, 1
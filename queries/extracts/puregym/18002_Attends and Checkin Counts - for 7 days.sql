WITH 
  v0 AS
  (
    SELECT  /*+ materialized */
            attends.center center
          , centers.name center_name
          , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')  access_date        
          , nvl(booking_resources.coment, 'NEITHER') resource_cat
          , count(1) cat_count           
      FROM  attends  
        JOIN centers
          ON attends.center = centers.id                   
        JOIN booking_resources
          ON attends.booking_resource_center = booking_resources.center
         AND attends.booking_resource_id = booking_resources.id  
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$
        AND attends.start_time < + $$startdate$$ + 604800 * 1000        
        AND attends.center IN ($$scope$$) 
    GROUP BY attends.center
           , centers.name
           , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD') 
           , nvl(booking_resources.coment, 'NEITHER')
  ) 
, v1 as
  (
    SELECT   /*+ opt_param('_OPTIM_PEEK_USER_BINDS ',FALSE) */ 
            attends.center center
          , centers.name center_name
          , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')  access_date  
          , count(distinct attends.person_center || 'p' || attends.person_id) unique_attends 
          , count(distinct to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD HH24') || attends.person_center || 'p' || attends.person_id) hourly_unique_attends
      FROM  attends
        JOIN centers
          ON attends.center = centers.id                  
        JOIN booking_resources
          ON attends.booking_resource_center = booking_resources.center
         AND attends.booking_resource_id = booking_resources.id  
         AND NVL(booking_resources.coment, 'NEITHER') IN ('IN', 'DISABLED')         
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$
        AND attends.start_time < $$startdate$$ + 604800 * 1000           
        AND attends.center IN ($$scope$$) 
    GROUP BY attends.center
           , centers.name
           , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')      
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
              (MAX(nvl(cat_count, 0)) 
               FOR resource_cat IN ('IN' AS ATTENDS_IN, 'OUT' AS ATTENDS_OUT, 'DISABLED' AS ATTENDS_DISABLED, 'NEITHER' AS ATTENDS_OTHERS))   
  )
, v3 as  
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
SELECT  nvl(v2.center, v3.center) center
      , nvl(v2.center_name, v3.center_name) center_name
      , nvl(v2.access_date, v3.access_date) access_date
      , v2.attends_in
      , v2.attends_out
      , v2.attends_disabled
      , v2.attends_others
      , v1.unique_attends
      , v1.hourly_unique_attends
      , v3.checkins
      , v3.unique_checkins
 FROM v2
   FULL JOIN v1
          ON v2.center = v1.center
         AND v2.access_date = v1.access_date
   FULL JOIN v3
          ON v2.center = v3.center
         AND v2.access_date = v3.access_date  
ORDER BY 3, 1 
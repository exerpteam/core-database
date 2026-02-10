-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
  v0 AS
  (
    SELECT  /*+ materialized */
            attends.center center
          , centers.name center_name
          , attends.person_center
          , attends.person_id    
          , attends.start_time         
          , nvl(booking_resources.coment, 'NEITHER') resource_cat
          , to_char(longtodateTZ(attends.start_time,'Europe/London') , 'YYYY-MM-DD')  access_date
          , CASE LAG( booking_resources.coment, 1, 'FIRST' ) OVER (PARTITION BY attends.center, attends.person_center, attends.person_id ORDER BY attends.start_time)
              WHEN 'IN' THEN
                CASE booking_resources.coment                   
                  WHEN 'IN' THEN 
                    CASE
                      WHEN attends.start_time - $$hours_unique_attends$$ *3600*1000 > LAG( attends.start_time, 1 ) OVER (PARTITION BY attends.center, attends.person_center, attends.person_id ORDER BY attends.start_time)
                      THEN 'PREV-CHECKIN-MORETHAN'
                      ELSE 'DELETE'
                    END
                  WHEN 'DISABLED' THEN 'DISABLED'
                  WHEN 'OUT' THEN 'CHECKOUT'
                END
              WHEN 'OUT' THEN
                CASE booking_resources.coment 
                  WHEN 'IN' THEN 'CHECKIN'
                  WHEN 'DISABLED' THEN 'DISABLED'
                  WHEN 'OUT' THEN 
                    CASE
                      WHEN attends.start_time - $$hours_unique_attends$$ *3600*1000 > LAG( attends.start_time, 1 ) OVER (PARTITION BY attends.center, attends.person_center, attends.person_id ORDER BY attends.start_time)
                      THEN 'PREV-CHECKOUT-MORETHAN'
                      ELSE 'DELETE'
                    END
                END                
              WHEN 'DISABLED' THEN
                CASE booking_resources.coment 
                  WHEN 'IN' THEN 'CHECKIN'
                  WHEN 'DISABLED' THEN 'DISABLED'
                  WHEN 'OUT' THEN 'CHECKOUT'
                END  
              WHEN 'FIRST' THEN
                CASE booking_resources.coment 
                  WHEN 'IN' THEN 'CHECKIN'
                  WHEN 'DISABLED' THEN 'DISABLED'
                  WHEN 'OUT' THEN 'ONLY-CHECKOUT'
                END                                  
            END flag              
      FROM  attends  
        JOIN centers
          ON attends.center = centers.id                   
        JOIN booking_resources
          ON attends.booking_resource_center = booking_resources.center
         AND attends.booking_resource_id = booking_resources.id  
         AND nvl(booking_resources.coment, 'NEITHER') in ('IN', 'DISABLED', 'OUT') 
        JOIN state_change_log
          ON attends.person_center = state_change_log.center
         AND attends.person_id = state_change_log.id
         AND state_change_log.entry_type = 5  
         AND attends.start_time between state_change_log.entry_start_time and nvl(state_change_log.entry_end_time, attends.start_time)
         AND state_change_log.stateid = 2                         
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$ 
        AND attends.start_time < $$startdate$$ + 604800 * 1000            
  ) 
, v1 as  
  (
     SELECT  /*+ inline */
         center
       , center_name
       , access_date
       , flag
       , count(1) attends_count 
     FROM v0
     GROUP BY
         center
       , center_name
       , access_date
       , flag   
  )
, v2 as  
  (
     SELECT  /*+ inline */
         * 
     FROM
         (SELECT center
               , center_name
               , access_date
               , flag
               , attends_count
            FROM v1)
          PIVOT
              (MAX(nvl(attends_count, 0)) 
               FOR flag IN ('CHECKIN' AS CHECKIN, 'CHECKOUT' AS CHECKOUT, 'DISABLED' AS DISABLED, 'ONLY-CHECKOUT' AS ONLY_CHECKOUT, 'PREV-CHECKIN-MORETHAN' AS PREV_CHECKIN_MORETHAN,'PREV-CHECKOUT-MORETHAN' AS PREV_CHECKOUT_MORETHAN, 'DELETE' AS DELETES))
  )
select * 
from v2
order by 3,1
WITH 
  v0 AS
  (
    SELECT  /*+ materialized */
            attends.center center
          , centers.name center_name
          , attends.person_center
          , attends.person_id  
          , entityidentifiers.identity pin  
          , attends.start_time         
          , coalesce(booking_resources.coment, 'NEITHER') resource_cat
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
         AND coalesce(booking_resources.coment, 'NEITHER') in ('IN', 'DISABLED', 'OUT')
        LEFT JOIN entityidentifiers 
               ON entityidentifiers.ref_center = attends.person_center 
              AND entityidentifiers.ref_id = attends.person_id 
              AND entityidentifiers.ref_type = 1 
              AND entityidentifiers.idmethod = 5 
              AND entityidentifiers.entitystatus = 1  
        JOIN state_change_log
          ON attends.person_center = state_change_log.center
         AND attends.person_id = state_change_log.id
         AND state_change_log.entry_type = 5  
         AND attends.start_time between state_change_log.entry_start_time and coalesce(state_change_log.entry_end_time, attends.start_time)
         AND state_change_log.stateid = 2                         
      WHERE attends.state = 'ACTIVE'
        AND attends.start_time >= $$startdate$$ 
        AND attends.start_time < $$startdate$$ + 86400 * 1000  
        AND attends.center = $$center$$
  ) 
select v0.center
     , v0.center_name
     , v0.person_center
     , v0.person_id  
     , v0.pin  
     , v0.access_date
     , to_char(longtodateTZ(v0.start_time,'Europe/London'), 'HH24:MI:SS') access_time
     , '''' || v0.start_time         
     , v0.resource_cat
     , v0.flag || case v0.flag  when 'PREV-CHECKIN-MORETHAN' then  $$hours_unique_attends$$  when 'PREV-CHECKOUT-MORETHAN' then  $$hours_unique_attends$$  else null end flag
from v0
order by 1, 2, 3, 4, 6
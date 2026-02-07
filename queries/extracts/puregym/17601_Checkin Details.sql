with v1 as (
      SELECT /*+ materialized */
        checkins.person_center
      , checkins.id
      , checkins.person_id
      , checkins.checkin_center
      , entityidentifiers.identity pin
      , checkins.checkin_time
      , checkins.checkout_time      
      , CASE 
          WHEN checkins.checkin_time BETWEEN LAG(checkins.checkin_time, 1 )  OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
                                AND LAG(checkins.checkout_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
            THEN  LAG(checkins.id, 1) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
          ELSE  
            NULL
        END AS PARENT_ID
      , CASE 
          WHEN checkins.checkin_time BETWEEN LAG(checkins.checkin_time, 1 )  OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
                                AND LAG(checkins.checkout_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
            THEN  LAG(checkins.checkin_time, 1 )  OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time)
          ELSE  
            NULL
        END AS PARENT_CHECKIN
      , CASE 
          WHEN checkins.checkin_time BETWEEN LAG(checkins.checkin_time, 1 )  OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
                                AND LAG(checkins.checkout_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) 
            THEN  LAG(checkins.checkout_time, 1 )  OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time)
          ELSE  
            NULL
        END AS PARENT_CHECKOUT                
      FROM  checkins
        LEFT JOIN entityidentifiers 
          ON  entityidentifiers.ref_center = checkins.person_center 
          AND entityidentifiers.ref_id = checkins.person_id 
          AND entityidentifiers.ref_type = 1 
          AND entityidentifiers.idmethod = 5 
          AND entityidentifiers.entitystatus = 1 
      WHERE     
            checkins.checkin_center = $$checkin_center$$
        AND checkins.checkin_time >= $$checkin_startdate$$
        AND checkins.checkin_time <= $$checkin_enddate$$          
     )    
   , v2 as (      
        SELECT /*+ materialized */
        v1.id
      , v1.person_center
      , v1.person_id    
      , v1.checkin_center
      , v1.pin
      , v1.checkin_time
      , v1.checkout_time
      , LEVEL pos_level
      , v1.parent_id
      , v1.parent_checkin
      , v1.parent_checkout
      , CONNECT_BY_ROOT id root_id     
      , CONNECT_BY_ROOT checkin_time root_checkin
      , CONNECT_BY_ROOT checkout_time root_checkout
      FROM v1
      START WITH parent_id IS NULL
      CONNECT BY PRIOR id = parent_id
     )  
   , v3 as (      
        SELECT /*+ materialized */    
        v2.*  
      , CASE 
        WHEN v2.pos_level = 1 
          THEN 'OK'
        ELSE
          (CASE WHEN v2.parent_id = v2.root_id OR v2.checkin_time between v2.ROOT_CHECKIN AND v2.ROOT_CHECKOUT 
             THEN 'DELETE'
           ELSE           
             (CASE WHEN v2.parent_checkin BETWEEN v2.ROOT_CHECKIN AND v2.ROOT_CHECKOUT 
                THEN 'KEEP'
              ELSE
                'DELETE'
              END)
          END)      
        END DECISION_FLAG
      FROM v2
    )
  SELECT
        v3.checkin_center               
      , to_char(longtodateTZ(v3.checkin_time,'Europe/London') , 'YYYY-MM-DD') checkin_date
      , to_char(longtodateTZ(v3.checkin_time,'Europe/London') , 'HH24') checkin_hour
      , v3.id checkin_id
      , v3.person_center
      , v3.person_id        
      , v3.pin  
      , longtodateTZ(v3.checkin_time,'Europe/London') checkin
      , longtodateTZ(v3.checkout_time,'Europe/London') checkout
      , v3.pos_level hierarchy_level
      , v3.parent_id parent_checkin_id
      , longtodateTZ(v3.parent_checkin,'Europe/London') parent_checkin
      , longtodateTZ(v3.parent_checkout,'Europe/London') parent_checkout
      , v3.root_id  root_checkin_id   
      , longtodateTZ(v3.root_checkin,'Europe/London') root_checkin
      , longtodateTZ(v3.root_checkout,'Europe/London') root_checkout
      , v3.decision_flag
  FROM v3
  ORDER BY checkin_center
       , person_center
       , person_id   
       , checkin_date
       , checkin_hour
       , checkin  
       , hierarchy_level     
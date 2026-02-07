WITH
    params AS
    (
        SELECT            
            (TRUNC(SYSDATE)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000 AS TODATE
        FROM
            dual
    )
SELECT /*+ INDEX(b IDX_BOOKINGS_START) */ 
       b.center || 'bk' || b.id booking_id
     , b.name name 
     , b.center center_id 
     , b.activity activity_id
     , cg.name color     
     , to_char(longtodateC(b.starttime, b.center), 'YYYY-MM-DD HH24:MI') AS start_date_time
     , to_char(longtodateC(b.stoptime, b.center), 'YYYY-MM-DD HH24:MI') AS stop_date_time 
,to_char(longtodateC(b.creation_time, b.center), 'YYYY-MM-DD HH24:MI') AS creation_date_time
     , b.state state
     , nvl(b.class_capacity, 0) class_capacity
     , nvl(b.waiting_list_capacity, 0) waiting_list_capacity
     , b.last_modified ets
 FROM bookings b
CROSS JOIN params
 JOIN CENTERS c
   ON c.id = b.center  
 JOIN activity a
   ON a.id = b.activity  
 LEFT JOIN COLOUR_GROUPS cg
   ON (b.COLOUR_GROUP_ID = cg.ID
       AND b.COLOUR_GROUP_ID IS NOT NULL
      )        
WHERE b.starttime >= 1451602800000
  AND b.starttime < params.TODATE
  AND b.center in ($$scope$$)
  AND b.center NOT BETWEEN 300 and 399 /*Closed Danish clubs in SATS*/
 order by 1
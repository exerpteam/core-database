SELECT /*+ INDEX(p IDX_START_TIME) */ 
       p.center || 'par' || p.id participation_id  
   , p.booking_center || 'bk' || p.booking_id booking_id
   , cp.external_id person_id
, to_char(longtodate(p.creation_time), 'YYYY-MM-DD HH24:MI') creation_date_time 
     , p.state
     , DECODE (p.user_interface_type, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT','UNKNOWN') user_interface_type
     , to_char(longtodateC(p.showup_time, p.center), 'YYYY-MM-DD HH24:MI') show_up_time 
     , DECODE (p.showup_interface_type, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT','UNKNOWN') show_up_interface_type
     , decode(p.showup_using_card, 1, 'TRUE', 0, 'FALSE', 'UNKNOWN')
     , to_char(longtodateC(p.cancelation_time, p.center), 'YYYY-MM-DD HH24:MI') cancel_time
     , DECODE (p.cancelation_interface_type, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT','UNKNOWN') cancel_interface_type
     , p.cancelation_reason cancel_reason
     , decode(p.on_waiting_list, 1, 'TRUE', 0, 'FALSE') as_on_waiting_list
     , p.last_modified ets 
 FROM participations p
 JOIN bookings b
   ON p.booking_center = b.center
  AND p.booking_id = b.id
 JOIN CENTERS c
   ON p.center = c.id
 JOIN persons per
   ON per.center = p.participant_center
  AND per.id = p.participant_id
 JOIN PERSONS cp
   ON cp.CENTER = per.CURRENT_PERSON_CENTER
  AND cp.id = per.CURRENT_PERSON_ID
WHERE p.start_time >= $$startdate$$
  AND p.start_time < $$enddate$$
  AND p.center in ($$scope$$)
  AND p.center NOT BETWEEN 300 and 399 /*Closed Danish clubs in SATS*/
 order by 1
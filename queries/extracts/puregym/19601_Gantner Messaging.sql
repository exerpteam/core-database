SELECT centers.id AS "Club Id"
     , centers.name AS "Club Name"
     , TRUNC(longtodateTZ(messages.senttime, 'Europe/London')) AS "Delivery Date"          
     , DECODE(messages.deliverycode, 2, 'EMAIL', 6, 'SMS') AS "Delivery Method"     
     , messages.subject AS "Subject"
     , count(1) AS "Message Count"
  FROM messages
    JOIN centers
      ON messages.center = centers.id
    JOIN event_type_config
      ON messages.message_type_id = event_type_config.event_type_id  
     AND event_type_config.event_type_id = 120    
 WHERE messages.center in ($$scope$$)
   AND messages.senttime >= $$startdate$$
   AND messages.senttime < $$enddate$$ + (86400 * 1000)
   AND messages.deliverycode IN (2, 6)
GROUP BY centers.id 
       , centers.name
       , TRUNC(longtodateTZ(messages.senttime, 'Europe/London'))     
       , DECODE(messages.deliverycode, 2, 'EMAIL', 6, 'SMS')
       , messages.subject
ORDER BY 1, 3, 4, 5   
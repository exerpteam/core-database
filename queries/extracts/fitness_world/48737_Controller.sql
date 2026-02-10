-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
v0 AS
(
SELECT  substr(messages.subject, instr(messages.subject, ' IN ') + 4) club_name      
      , messages.senttime offline_time
      , CASE message_type_id 
          WHEN 124 THEN
            CASE LEAD(message_type_id, 1) OVER (PARTITION BY substr(messages.subject, instr(messages.subject, ' IN ') + 4) ORDER BY messages.senttime)
            WHEN 125 THEN
              LEAD(senttime, 1) OVER (PARTITION BY substr(messages.subject, instr(messages.subject, ' IN ') + 4) ORDER BY messages.senttime)
            ELSE
              NULL
            END
          ELSE
            NULL
        END AS online_time
      , message_type_id
  FROM messages
    JOIN event_type_config
      ON messages.message_type_id = event_type_config.event_type_id  
     AND event_type_config.event_type_id in (124, 125)
     AND event_type_config.state = 'ACTIVE'
     --AND messages.id = 201
 WHERE 1=1
   AND messages.senttime >= $$startdate$$
   AND messages.senttime < $$enddate$$ + (86400 * 1000)
   AND messages.deliverycode = 2
)
SELECT  v0.club_name
      , to_char(longtodateTZ(v0.offline_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') offline_time
      , to_char(longtodateTZ(v0.online_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') online_time
      , round((v0.online_time - v0.offline_time) / (60 * 1000), 2) downtime_mins
FROM  v0
WHERE v0.message_type_id = 124
ORDER BY 1, 2

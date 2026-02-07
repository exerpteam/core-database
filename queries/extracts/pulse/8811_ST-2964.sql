 WITH
     att AS
     (
         SELECT
             att_hour,
             TO_CHAR(att_date,'yyyy-MM-dd')                      AS att_date,
             TO_CHAR(att_date,'DAY') AS date_day,
             BOOKING_RESOURCE_CENTER,
             BOOKING_RESOURCE_ID,
             COUNT(*) AS total
         FROM
             (
                 SELECT
                     date_trunc('day', longtodateC(att.START_TIME, att.center)) AS att_date,
                     TO_CHAR(longtodateC(att.START_TIME, att.center), 'HH24') AS att_hour,
                     att.BOOKING_RESOURCE_CENTER,
                     att.BOOKING_RESOURCE_ID
                 FROM
                     ATTENDS att
                 WHERE
                     att.center IN ($$scope$$)
                     AND att.state = 'ACTIVE'
                     AND att.START_TIME BETWEEN $$from_date$$ AND $$to_date$$ 
                  ) t1
         GROUP BY
             att_hour,
             att_date,
             BOOKING_RESOURCE_CENTER,
             BOOKING_RESOURCE_ID
     )
 SELECT
     br.CENTER                                     AS CENTER_ID,
     br.NAME                                       AS RESOURCE_NAME,
     att.att_date                                  AS SWIPE_DATE,
     att.date_day                                  AS SWIPE_DAY,
     att.att_hour||':00-'||(CAST(att.att_hour as integer)+1)||':00' AS SWIPE_TIME,
     att.total                                     AS SWIPE_COUNT
 FROM
     BOOKING_RESOURCES br
 JOIN
     att
 ON
     att.BOOKING_RESOURCE_CENTER = br.center
     AND att.BOOKING_RESOURCE_ID = br.id
 WHERE
     br.center IN ($$scope$$)
     AND br.ATTENDABLE =1
     AND br.STATE = 'ACTIVE'
 ORDER BY
     br.CENTER,
     br.NAME,
     att.att_date,
     att.att_hour

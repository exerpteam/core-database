-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-13183
 WITH
     params AS MATERIALIZED
     (
         SELECT
             $$StartDate$$                      AS FromDateTime,
             $$EndDate$$ + (24*60*60*1000) -1 AS ToDateTime,
             2*60                            AS attendThreshold
         
     )
 SELECT
     c.id                                  AS "Center Id",
     c.shortname                           AS "Center Name",
     t.PERSON_CENTER || 'p' || t.PERSON_ID AS "Member Id",
     t.external_id                         AS "Member External Id",
     TO_CHAR(t.checkinTime, 'DD-MM-YYYY')  AS "Check in Date",
     TO_CHAR(t.checkinTime, 'HH24:MI')     AS "Check in Time",
     TO_CHAR(t.checkoutTime, 'HH24:MI')    AS "Check out Time",
     TO_CHAR(t.attend_start, 'HH24:MI')    AS "Attend Time",
     t.resourceName                        AS "Resource Name",
         CASE scl.stateid WHEN 2 THEN 'Active' WHEN 3 THEN 'Ended' WHEN 4 THEN 'Frozen' WHEN 7 THEN 'Window' WHEN 8 THEN 'Created' ELSE 'Undefined' END AS "Subscription State"
 FROM
     (
         SELECT
             c.PERSON_CENTER,
             c.PERSON_ID,
             c.CHECKIN_CENTER,
             p.external_id,
             COUNT(*),
             longtodatec(c.CHECKIN_TIME, c.CHECKIN_CENTER)      AS checkinTime,
             longtodatec(c.checkout_time, c.CHECKIN_CENTER)     AS checkoutTime,
             (MIN(att.START_TIME)-c.CHECKIN_TIME)/1000          AS attCheckdiff,
             longtodatec(MIN(att.START_TIME), c.CHECKIN_CENTER) AS attend_start,
             MIN(att.START_TIME)                                AS attendStartTime,
             c.CHECKIN_TIME,
             MIN(br.name) AS resourceName
         FROM
             CHECKINS c
         CROSS JOIN
             params
         JOIN
             persons p
         ON
             p.center = c.PERSON_CENTER
             AND p.id = c.PERSON_id
         JOIN
             ATTENDS att
         ON
             c.PERSON_CENTER = att.PERSON_CENTER
             AND c.PERSON_ID = att.PERSON_ID
             AND att.START_TIME >= c.CHECKIN_TIME - (30*1000) --(Attend can register before checkin. So 30 sec correction time)
             AND att.START_TIME <= c.CHECKOUT_TIME
         JOIN
             BOOKING_RESOURCES br
         ON
             br.center = att.BOOKING_RESOURCE_CENTER
             AND br.id = att.BOOKING_RESOURCE_ID
         WHERE
             c.PERSON_CENTER IN ($$Scope$$)
             AND p.persontype != 2 -- exclude staff
             AND c.CHECKIN_TIME BETWEEN params.FromDateTime AND params.ToDateTime
             AND c.CHECKOUT_TIME - c.CHECKIN_TIME = 0
         GROUP BY
             p.external_id,
             c.PERSON_CENTER,
             c.PERSON_ID,
             c.CHECKIN_TIME,
             c.CHECKIN_CENTER,
             c.checkout_time
         HAVING
             COUNT(*) = 1 ) t
 CROSS JOIN
     params
 JOIN
     centers c
 ON
     c.id = t.CHECKIN_CENTER
 LEFT JOIN
     subscriptions s
 ON
     s.owner_center = t.PERSON_CENTER
     AND s.owner_id = t.PERSON_ID
 LEFT JOIN
     STATE_CHANGE_LOG SCL
 ON
     scl.center = s.center
     AND scl.id = s.id
     AND scl.ENTRY_TYPE = 2
     AND scl.book_start_time <= t.CHECKIN_TIME
     AND COALESCE(scl.book_end_time, t.CHECKIN_TIME ) >= t.CHECKIN_TIME
 WHERE
     ABS(t.attCheckdiff) <= params.attendThreshold

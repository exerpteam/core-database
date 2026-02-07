/* INSERT INTO PREFERRED_CENTERS(PERSON_CENTER, PERSON_ID, PREFERRED_CENTER) */
WITH 
  chkin_counts As
  (
  SELECT  p.current_person_center
        , p.current_person_id
        , c.checkin_center
        , max(c.checkin_time) latest_checkin_time
        , count(c.id) chkin_count
    FROM  PERSONS p
    JOIN  checkins c
      ON  c.person_center = p.center
     AND  c.person_id = p.id
     AND  c.checkin_center != p.current_person_center 
     AND  c.checkin_time between dateToLongTZ(to_char(add_months(trunc(sysdate), -6), 'YYYY-MM-dd HH24:MI'),'Europe/London') AND dateToLongTZ(to_char(trunc(sysdate), 'YYYY-MM-dd HH24:MI'),'Europe/London')
   WHERE  p.status not in (5, 7, 8) /* Duplicate, Deleted, Anonymized */
  GROUP BY  p.current_person_center, p.current_person_id, c.checkin_center
  ) 
, ranked_chkin_counts AS
  (
  SELECT chkin_counts.current_person_center
       , chkin_counts.current_person_id
       , chkin_counts.checkin_center
       , chkin_counts.chkin_count
       , chkin_counts.latest_checkin_time
       , rank() over (partition by chkin_counts.current_person_center, chkin_counts.current_person_id order by chkin_counts.chkin_count desc, latest_checkin_time desc) center_rank
  FROM chkin_counts
  )
SELECT ranked_chkin_counts.current_person_center AS PERSON_CENTER
     , ranked_chkin_counts.current_person_id AS PERSON_ID
     , ranked_chkin_counts.checkin_center AS PREFERRED_CENTER
FROM ranked_chkin_counts
WHERE center_rank <= 5
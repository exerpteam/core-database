-- The extract is extracted from Exerp on 2026-02-08
--  
WITH member_daily AS (
    SELECT
        c.person_center,
        c.person_id,
        TO_CHAR(longtodate(c.checkin_time), 'DD-MM-YYYY') AS checkin_date,
        c.checkin_center
    FROM checkins c
    WHERE
        c.checkin_time >= (:CHECKIN_TIME_FROM)
        AND c.checkin_time <= (:CHECKIN_TIME_TO)
        AND c.origin = 4
		AND c.checkin_center IN (:CENTER)
),
member_agg AS (
    SELECT
        person_center,
        person_id,
        COUNT(DISTINCT checkin_date) AS unique_visits,
        COUNT(DISTINCT checkin_center) AS unique_centers_visited,
        MAX(daily_count) AS max_checkins_per_day
    FROM (
        SELECT
            person_center,
            person_id,
            checkin_date,
            checkin_center,
            COUNT(*) OVER (PARTITION BY person_center, person_id, checkin_date) AS daily_count
        FROM member_daily
    ) sub
    GROUP BY person_center, person_id
)
SELECT
    p.center || 'p' || p.id AS "MemberID",
    ma.unique_visits AS "Unique Visits",
    ma.unique_centers_visited AS "Unique Centers Visited",
    ma.max_checkins_per_day AS "Max Checkins per Day"
FROM member_agg ma
JOIN persons p 
  ON p.center = ma.person_center 
 AND p.id = ma.person_id
WHERE p.persontype !=2
ORDER BY "MemberID";
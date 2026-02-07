WITH
  params AS (
    SELECT
      datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
      c.id AS CENTER_ID,
      CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
      centers c
  ),

  raw_class_data AS (
    SELECT
      b.center,
      b.id AS booking_id,
      TO_CHAR(longtodateC(b.starttime, b.center), 'YYYY-MM-DD HH24:MI') AS start_time,
      TO_CHAR(longtodateC(b.stoptime, b.center), 'YYYY-MM-DD HH24:MI') AS end_time,
      ac.id AS activity_id,
      ac.name AS class_name,
      b.state AS status,
      c.name AS club,
      COALESCE(booked.booked, 0) AS booked_members,
      COALESCE(p.participants, 0) AS attended_members,
      b.class_capacity,
      ins.fullname AS instructor,
      TRIM(TO_CHAR(longtodateC(b.starttime, b.center), 'Day')) AS weekday,
      TO_CHAR(longtodateC(b.starttime, b.center), 'HH24:MI') AS time_of_day
    FROM fernwood.bookings b
    LEFT JOIN (
      SELECT
        booking_center,
        booking_id,
        COUNT(*) AS booked
      FROM fernwood.participations
      WHERE
        (cancelation_reason NOT IN ('USER', 'BOOKING', 'CENTER', 'API') OR cancelation_reason IS NULL)
      GROUP BY booking_center, booking_id
    ) booked ON booked.booking_center = b.center AND booked.booking_id = b.id
    LEFT JOIN (
      SELECT
        booking_center,
        booking_id,
        COUNT(*) AS participants
      FROM fernwood.participations
      WHERE state = 'PARTICIPATION'
      GROUP BY booking_center, booking_id
    ) p ON p.booking_center = b.center AND p.booking_id = b.id
    JOIN fernwood.centers c ON c.id = b.center
    JOIN fernwood.activity ac ON b.activity = ac.id
    JOIN params ON params.CENTER_ID = b.center
    JOIN fernwood.staff_usage su ON su.booking_center = b.center AND su.booking_id = b.id AND su.cancellation_time IS NULL
    JOIN fernwood.persons ins ON ins.center = su.person_center AND ins.id = su.person_id
WHERE
  b.starttime BETWEEN params.FromDate AND params.ToDate
  AND ac.activity_group_id NOT IN (201,17,1201,801,10,401,402,1401,1601,2601,2401)
  AND b.state != 'CANCELLED'
  AND b.center IN (:Scope)
  AND ac.name NOT ILIKE '%virtual%'
  AND ac.name NOT ILIKE '%FIIT30%'
  AND ac.name NOT ILIKE '%on demand%'
  AND ac.name NOT IN ('Staff Break 30 Mins', 'Complimentary Personal Training Session','Gym Floor Session','HYPOXI Staff Availability','Massage Therapist Availability','Nutrition Coaching Availability','HYPOXI Availability','FITNESS COACH 30 MINS')
  ),
  low_attendance_summary AS (
    SELECT
      activity_id,
      class_name,
      instructor,
      club,
      weekday,
      time_of_day,
      COUNT(*) AS low_attendance_count
    FROM raw_class_data
    WHERE attended_members <= 7
    GROUP BY activity_id, class_name, instructor, club, weekday, time_of_day
    HAVING COUNT(*) > 3
  )

SELECT
  r.start_time AS "Start Time",
  r.end_time AS "End Time",
  r.weekday || ' ' || r.time_of_day AS "Day & Time",
  r.class_name AS "Class Name",
  r.status AS "Status",
  r.club AS "Club",
  r.booked_members AS "Number of Booked Members",
  r.attended_members AS "Number of Attended Members",
  r.class_capacity AS "Class Capacity",
  r.instructor AS "Instructor",
  r.weekday AS "Day of Week",
  r.time_of_day AS "Class Time"
FROM raw_class_data r
JOIN low_attendance_summary las
  ON r.activity_id = las.activity_id
  AND r.class_name = las.class_name
  AND r.instructor = las.instructor
  AND r.club = las.club
  AND r.weekday = las.weekday
  AND r.time_of_day = las.time_of_day
WHERE r.attended_members <= 7
ORDER BY r.weekday, r.time_of_day, r.club, r.class_name, r.start_time;

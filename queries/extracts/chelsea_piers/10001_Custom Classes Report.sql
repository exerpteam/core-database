SELECT
t1.center as "Center ID",
t1.center_name as "Center",
t1.booking_date as "Date",
CASE 
WHEN EXTRACT(DOW from t1.booking_date) = 0
THEN 'Sunday'
WHEN EXTRACT(DOW from t1.booking_date) = 1
THEN 'Monday'
WHEN EXTRACT(DOW from t1.booking_date) = 2
THEN 'Tuesday'
WHEN EXTRACT(DOW from t1.booking_date) = 3
THEN 'Wednesday'
WHEN EXTRACT(DOW from t1.booking_date) = 4
THEN 'Thursday'
WHEN EXTRACT(DOW from t1.booking_date) = 5
THEN 'Friday'
WHEN EXTRACT(DOW from t1.booking_date) = 6
THEN 'Saturday'
END as "Weekday",
t1.start_time as "Start Time",
t1.booking_name as "Name",
t1.activity_group as "Activity Group",
t1.color_group as "Color Group",
t1.trainer as "Instructor",
t1.payroll as "Payroll",
AGE(t1.booking_stop, t1.booking_start) as "Duration",
t1.class_capacity as "Capacity",
t1.bookings as "Bookings",
CASE WHEN t1.class_capacity > 0 THEN
t1.bookings/t1.class_capacity * 100 || '%' 
ELSE ' '
END as "Booking Percentage",
t1.showups as "Showups",
CASE WHEN t1.bookings > 0
THEN t1.showups/t1.bookings * 100 || '%'
ELSE ' '
END as "Showup Percentage",
t1.absentees as "Absentees",
CASE WHEN t1.bookings > 0
THEN t1.absentees/t1.bookings * 100 || '%'
ELSE ' '
END as "Absentee Percentage"

from
(SELECT
    b.center,
    c.name as center_name,
    a.name                                     AS booking_name,
    ag.name                                    AS activity_group,
    cg.name                                    AS color_group,
    DATE(longtodateC(b.starttime, b.center))   AS booking_date,
    longtodateC(b.starttime, b.center) :: TIME AS start_time,
    longtodateC(b.starttime,b.center) as booking_start,
    longtodateC(b.stoptime, b.center) as booking_stop,
    per.fullname                               AS trainer,
    payroll.txtvalue                               AS payroll,
    b.starttime,
    b.stoptime,
    b.class_capacity,
    count (p.*) AS Bookings,
    count(p_showups.*) as Showups,
    count(p_cancelled.*) AS Absentees
FROM
    chelseapiers.bookings b
JOIN
    chelseapiers.activity a
ON
    b.activity = a.id
JOIN chelseapiers.centers c
     ON b.center = c.id
JOIN
    chelseapiers.activity_group ag
ON
    a.activity_group_id = ag.id
LEFT JOIN
    chelseapiers.colour_groups cg
ON
    a.colour_group_id = cg.id
LEFT JOIN
    chelseapiers.staff_usage su
ON
    su.booking_center = b.center
AND su.booking_id = b.id
JOIN
    chelseapiers.persons per
ON
    su.person_center = per.center
AND su.person_id = per.id
AND su.state = 'ACTIVE'
LEFT JOIN
    chelseapiers.person_ext_attrs payroll
ON
    per.center = payroll.personcenter
AND per.id = payroll.personid
AND payroll.name = '_eClub_EmployeeTitle'

LEFT join chelseapiers.participations p
    on p.booking_center = b.center and p.booking_id = b.id
    and p.state IN ('BOOKED','PARTICIPATION','CANCELLED','TENTATIVE')
LEFT join chelseapiers.participations p_showups
    on p_showups.booking_center = b.center and p_showups.booking_id = b.id
    and p_showups.state IN ('PARTICIPATION')
LEFT join chelseapiers.participations p_cancelled
    on p_cancelled.booking_center = b.center and p_cancelled.booking_id = b.id
    and p_cancelled.state IN ('CANCELLED')
WHERE
    b.center in (:scope)
    and b.starttime BETWEEN (:start_date) and (:end_date) 

GROUP BY 
  b.center,
  c.name,
  booking_name,
  activity_group,
  color_group,
  booking_date,
  b.starttime,
  b.stoptime,
  trainer,
  payroll,
  duration_list,
  class_capacity) t1
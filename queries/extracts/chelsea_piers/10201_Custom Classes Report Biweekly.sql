-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
    SELECT
        c.id AS center_id
      
    FROM centers c
    WHERE c.id in (:scope)            
),
base AS (
    SELECT
        b.center,
        c.name                     AS center_name,
        a.name                     AS booking_name,
        ag.name                    AS activity_group,
        cg.name                    AS color_group,

        longtodateC(b.starttime,b.center)  AS booking_start,
        longtodateC(b.stoptime ,b.center)  AS booking_stop,
        DATE(longtodateC(b.starttime,b.center))        AS booking_date,
        longtodateC(b.starttime,b.center)::time        AS start_time,

        string_agg(DISTINCT per.fullname, ', ' ORDER BY per.fullname) AS trainers,
        string_agg(DISTINCT payroll.txtvalue, ', '  ORDER BY payroll.txtvalue) AS payroll_titles,

        b.class_capacity,
     COUNT(DISTINCT p.id) FILTER (WHERE p.state IN ('BOOKED',
                                                           'PARTICIPATION',
                                                           'CANCELLED',
                                                           'TENTATIVE'))                AS bookings,
            COUNT(DISTINCT p.id) FILTER (WHERE p.state = 'PARTICIPATION') AS
            showups,
            COUNT(DISTINCT p.id) FILTER (WHERE p.state = 'CANCELLED') AS
            absentees
    FROM params
    JOIN chelseapiers.bookings            b  ON b.center = params.center_id
                                             AND b.starttime BETWEEN :start_date AND :end_date
    JOIN chelseapiers.activity            a  ON a.id   = b.activity
    JOIN chelseapiers.activity_group      ag ON ag.id  = a.activity_group_id
    LEFT JOIN chelseapiers.colour_groups  cg ON cg.id  = a.colour_group_id
    JOIN chelseapiers.centers             c  ON c.id   = b.center


    LEFT JOIN chelseapiers.staff_usage    su ON su.booking_center = b.center
                                             AND su.booking_id    = b.id
                                             AND su.state = 'ACTIVE'
    LEFT JOIN chelseapiers.persons        per ON per.center = su.person_center
                                             AND per.id     = su.person_id
    LEFT JOIN chelseapiers.person_ext_attrs payroll
                                ON payroll.personcenter = per.center
                               AND payroll.personid     = per.id
                               AND payroll.name         = '_eClub_EmployeeTitle'

    LEFT JOIN chelseapiers.participations p
                               ON p.booking_center = b.center
                              AND p.booking_id     = b.id

    GROUP BY
        b.center, c.name, a.name, ag.name, cg.name,
        booking_start, booking_stop, booking_date, start_time,
        b.class_capacity
)
SELECT
    center                    AS "Center ID",
    center_name               AS "Center",
    booking_date              AS "Date",
    to_char(booking_date,'Dy')AS "Weekday",
    start_time                AS "Start Time",
    booking_name              AS "Name",
    activity_group            AS "Activity Group",
    color_group               AS "Color Group",
    trainers                  AS "Instructor(s)",         
    payroll_titles            AS "Payroll",
    age(booking_stop,booking_start) AS "Duration",
    class_capacity            AS "Capacity",
    bookings                  AS "Bookings",
    CASE WHEN class_capacity>0
         THEN to_char(bookings*100.0/class_capacity,'FM999990.00')||'%'
    END                     AS "Booking %",
    showups                  AS "Showups",
    CASE WHEN bookings>0
         THEN to_char(showups*100.0/bookings,'FM999990.00')||'%'
    END                     AS "Showup %",
    absentees                AS "Absentees",
    CASE WHEN bookings>0
         THEN to_char(absentees*100.0/bookings,'FM999990.00')||'%'
    END                     AS "Absentee %"
FROM base
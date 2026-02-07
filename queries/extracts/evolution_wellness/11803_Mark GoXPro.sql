SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        CAST(dateToLongC(TO_CHAR(TO_DATE(:cutdate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS BIGINT) AS cutDate,
                        c.id
                FROM
                        centers c
        )
        SELECT 
                p.fullname AS "Client Name",
                b.center AS "Center ID",
                b.activity AS "Activity ID",
                p.external_id AS "External ID",
                pa.state AS "Participation Status",
                b.center || 'book' || b.id AS "Booking ID",
                TO_CHAR(longtodatec(b.starttime, b.center),'YYYY-MM-DD HH24:MI') as "Start Date and Time",
                TO_CHAR(longtodatec(b.stoptime, b.center),'YYYY-MM-DD HH24:MI') as "End At",
                b.class_capacity AS "Max Client Quantity",
                b.name AS "Activity Name",
                b.main_booking_id AS "First Booking ID",
                (CASE 
                        WHEN b.main_booking_center IS NOT NULL AND main.recurrence_type IS NULL THEN NULL
                        WHEN b.main_booking_center IS NULL AND b.recurrence_type IS NULL THEN NULL
                        WHEN b.main_booking_center IS NULL AND  b.recurrence_type=1 THEN 'daily'
                        WHEN b.main_booking_center IS NULL AND  b.recurrence_type=2 THEN 'weekly'
                        WHEN b.main_booking_center IS NULL AND  b.recurrence_type=3 THEN 'monthly'
                        WHEN b.main_booking_center IS NOT NULL AND  main.recurrence_type=1 THEN 'daily'
                        WHEN b.main_booking_center IS NOT NULL AND  main.recurrence_type=2 THEN 'weekly'
                        WHEN b.main_booking_center IS NOT NULL AND  main.recurrence_type=3 THEN 'monthly'
                        ELSE 'null'
                END) AS "Frequency Type",
                (CASE 
                        WHEN b.main_booking_center IS NULL THEN b.recurrence_data
                        ELSE main.recurrence_data
                END) AS "Recurrance",
                (CASE 
                        WHEN b.main_booking_center IS NULL THEN b.recurrence_end
                        ELSE main.recurrence_end
                END) AS "Recurrance End Date",
                (CASE 
                        WHEN b.main_booking_center IS NULL THEN b.recurrence_for
                        ELSE main.recurrence_for
                END) AS "Recurrance Date",
                b.booking_program_id AS "Program ID",
                TO_CHAR(longtodatec(su.starttime, su.person_center),'YYYY-MM-DD HH24:MI') as "Coach Usage Start Time",
                TO_CHAR(longtodatec(su.stoptime, su.person_center),'YYYY-MM-DD HH24:MI') as "Coach Usage Stop Time",
                su.state as "Coach Usage",
                staff.fullname "Coach Name",
                staff.external_id AS "Coach Ref ID",
                b.coment AS "Notes",
                pa.id AS "Participation ID",
                pa.cancelation_reason AS "Cancelled By",
				rank() over( PARTITION by b.center, b.id ORDER BY su.state,su.id DESC) AS ranking
        FROM persons p
        JOIN participations pa ON p.center = pa.participant_center AND p.id = pa.participant_id
        JOIN bookings b ON pa.booking_center = b.center AND pa.booking_id = b.id
        JOIN activity a ON b.activity = a.id
        JOIN params par ON b.center = par.id
        LEFT JOIN staff_usage su on b.center = su.booking_center AND b.id = su.booking_id
        LEFT JOIN persons staff ON su.person_center = staff.center AND su.person_id = staff.id
        LEFT JOIN bookings main ON main.center = b.main_booking_center AND main.id = b.main_booking_id
        WHERE

                b.starttime > par.cutDate    
                AND a.activity_type = 4
) t1
WHERE ranking = 1
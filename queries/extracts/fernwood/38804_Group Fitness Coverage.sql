-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            datetolongC(
                TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),
                c.id
            ) AS FromDate,
            c.id AS CENTER_ID,
            CAST(
                (
                    datetolongC(
                        TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),
                        c.id
                    ) - 1
                ) AS BIGINT
            ) AS ToDate
        FROM centers c
        -- optional: restrict params to selected centres only
        -- WHERE c.id IN (:Scope)
    ),

    gf_attendance AS
    (
        SELECT
            b.center AS booking_center,
            p.id     AS person_id
        FROM participations part
        JOIN persons p
            ON p.center = part.participant_center
           AND p.id     = part.participant_id
        JOIN bookings b
            ON b.center = part.booking_center
           AND b.id     = part.booking_id
        JOIN activity ac
            ON ac.id = b.activity
        JOIN params
            ON params.CENTER_ID = b.center
        WHERE
            -- Date range
            b.starttime BETWEEN params.FromDate AND params.ToDate

            -- Only actual attendance
            AND part.state = 'PARTICIPATION'

            -- Exclude cancelled classes
            AND b.state != 'CANCELLED'

            -- Club filter
            AND b.center IN (:Scope)

            ------------------------------------------------------------------
            -- EXCLUDE UNWANTED CLASS NAMES
            ------------------------------------------------------------------
            AND ac.name <> 'Boot Camp'
            AND ac.name <> 'Reformer Refined 30 Mins'
            AND ac.name <> 'Complimentary EP 30 Minutes'
            AND ac.name <> 'Complimentary Personal Training 30 Minutes'
            AND ac.name <> 'Staff Break 15 Mins'
            AND ac.name <> 'Team Meeting'
            AND ac.name <> 'HYPOXI 40 min Session'
            AND ac.name <> 'Group PT'
            AND ac.name <> 'Staff Break'
            AND ac.name <> 'HYPOXI 30 min Session'
            AND ac.name <> 'Reformer Refined 60 Mins'
            AND ac.name <> 'Nutrition Coaching - Initial Consultation'
            AND ac.name <> 'Body Scan 15 minutes'
            AND ac.name <> 'Open Day FIIT30'
            AND ac.name <> 'Semi Private Pilates PT'
            AND ac.name <> 'FITNESS COACH 45 MINS'
            AND ac.name <> 'FITNESS COACH 15 MINS'
            AND ac.name <> 'FITNESS COACH 30 MINS'
            AND ac.name <> 'Gym Floor Session'
            AND ac.name <> 'HYPOXI Staff Availability'
            AND ac.name <> 'HYPOXI Availability'
            AND ac.name <> 'Nutrition Coaching Availability'
            AND ac.name <> 'Massage Therapist Availability'
            AND ac.name <> 'FITNESS COACH 60 MINS'
            AND ac.name <> 'Nutrition Coaching Comp Session'
            AND ac.name <> 'Kids Fitness'
            AND ac.name <> 'BODY SCAN 15 MINS'
            AND ac.name <> 'PERSONAL TRAINING 30 MINS'
            AND ac.name <> 'PERSONAL TRAINING 45 MINS'
            AND ac.name <> 'BODY SCAN 30 MINS'
            AND ac.name <> 'PERSONAL TRAINING 60 MINS'
            AND ac.name <> 'Your Fernwood Onboarding'
            AND ac.name <> 'REFORMER REFINED 30 MINS COMP'
            AND ac.name <> 'PILATES PT 60 MINS'
            AND ac.name <> 'Women''s Circle'
            AND ac.name <> 'HYPOXI Intro Session'
            AND ac.name <> 'Body Scan 30 minutes'
            AND ac.name <> 'Kids Fit Body Combat'
            AND ac.name <> 'Complimentary Nutrition Coach Session'
            AND ac.name <> 'Menopause Workshop'
            AND ac.name <> 'Run Club'
            AND ac.name <> 'Measurements'
            AND ac.name <> 'HYPOXI Information Session'
            AND ac.name <> 'Staff Break Darwin'
            AND ac.name <> 'Line Dancing Party'
            AND ac.name <> 'Massage Chair - 30 Minutes'
            AND ac.name <> 'Zumba Party'
            AND ac.name <> 'Nutrition Workshop'
            AND ac.name <> 'HYPOXI HDC 30 Min'
            AND ac.name <> 'Challenge Class'
            AND ac.name <> 'CHECKUP BODY SCAN 45 MIN'
            AND ac.name <> 'Fitness Coach 10 Mins'
            AND ac.name <> '24 Hour Onboarding'
            AND ac.name <> 'Body Scan 20 minutes'
            AND ac.name <> 'Body Scan - Follow Up'
            AND ac.name <> 'Buddy Personal Training 45 Minutes'
            AND ac.name <> 'Cardio Onboarding'
            AND ac.name <> 'Cell IQ Appointment FTG'
            AND ac.name <> 'Cell IQ Availability'
            AND ac.name <> 'Cell IQ Availability FTG'
            AND ac.name <> 'Chatbot Appointment'
            AND ac.name <> 'Class Pass Follow Up'
            AND ac.name <> 'Complimentary Personal Training Session'
            AND ac.name <> 'Exercise Physiologists Appointment (30 min)'
            AND ac.name <> 'Exercise Physiologists Appointment (60 min)'
            AND ac.name <> 'Exercise Physiologists Availability'
            AND ac.name <> 'Fernwood Tour'
            AND ac.name <> 'Fernwood Trainer Staff Availability'
            AND ac.name <> 'HDC Comp Session'
            AND ac.name <> 'Health & Wellness Check-In'
            AND ac.name <> 'Health & Wellness Check-In 15 Mins'
            AND ac.name <> 'Health & Wellness Check-In 30 Mins'
            AND ac.name <> 'Health & Wellness Check-In 30 Mins 2'
            AND ac.name <> 'Health & Wellness Check-In 45 Mins'
            AND ac.name <> 'Health & Wellness Check-In 45 Mins 2'
            AND ac.name <> 'Health & Wellness Check-In 60 Mins'
            AND ac.name <> 'Health & Wellness Check-In 60 Mins 2'
            AND ac.name <> 'HYPOXI 30 min Vacunaut'
            AND ac.name <> 'HYPOXI 35 min Session'
            AND ac.name <> 'HYPOXI Comp Session'
            AND ac.name <> 'HYPOXI Consultation'
            AND ac.name <> 'HYPOXI HDC 30 Min.'
            AND ac.name <> 'HYPOXI Intro 60 min Session'
            AND ac.name <> 'HYPOXI Phone Consultation'
            AND ac.name <> 'HYPOXI Staff Break'
            AND ac.name <> 'HYPOXI Tour'
            AND ac.name <> 'HYPOXI Vacunaut 40 min Session'
            AND ac.name <> 'HYPOXI Vacunaut 45 Min Session'
            AND ac.name <> 'Massage Chair Availability'
            AND ac.name <> 'Member Induction & Body Scan'
            AND ac.name <> 'Membership Request'
            AND ac.name <> 'Motivational Calls'
            AND ac.name <> 'New Member'
            AND ac.name <> 'New Member Appointment'
            AND ac.name <> 'New Member First Session'
            AND ac.name <> 'New Member - Week 1'
            AND ac.name <> 'New Member - Week 8'
            AND ac.name <> 'Prescribe Program (30 mins)'
            AND ac.name <> 'Prescribe Program Consultation (30 Mins)'
            AND ac.name <> 'Prescribe Program Walkthrough (30 Mins)'
            AND ac.name <> 'Recovery - 30 Minutes'
            AND ac.name <> 'Recovery Boots - 30 Minutes'
            AND ac.name <> 'Recovery - Fire & Ice'
            AND ac.name <> 'Recovery Lounge'
            AND ac.name <> 'Reformer Pilates 30 Mins'
            AND ac.name <> 'Renewal'
            AND ac.name <> 'Reschedule Appointment'
            AND ac.name <> 'Sales Staff Availability'
            AND ac.name <> 'Sauna'
            AND ac.name <> 'Sauna - 30 Minutes'
            AND ac.name <> 'Sauna - 35 Minutes'
            AND ac.name <> 'Sauna - 40 Minutes'
            AND ac.name <> 'Sauna - 45 Minutes'
            AND ac.name <> 'Sauna - 60 Minutes'
            AND ac.name <> 'Sauna Room'
            AND ac.name <> 'Sauna Room Availability'
            AND ac.name <> 'Staff Break 30 Mins'
            AND ac.name <> 'Staff Meeting'
            AND ac.name <> 'Strength & Cardio Onboarding'
            AND ac.name <> 'Strength Training Onboarding'
            AND ac.name <> 'Team Training'
            AND ac.name <> 'Trainer Availability'
            AND ac.name <> 'Trainer Availability Club'
            AND ac.name <> 'Childcare Session'
            AND ac.name <> 'Fitness Coach 15 Mins'
            AND ac.name <> 'Fitness Coach 30 Mins'
            AND ac.name <> 'Mobility Stretch'
            AND ac.name <> 'Phone Appointment'
            AND ac.name <> 'Personal Training 30 Mins'
            AND ac.name <> 'Body Scan'
            AND ac.name <> 'Discovery Day'
            AND ac.name <> 'Fitness Coach 10 Mins Old'
            AND ac.name <> 'Goal Setting'
            AND ac.name <> 'HDC Recovery'
            AND ac.name <> 'Health & Wellness Check-In 15 Mins 2'
            AND ac.name <> 'HYPOXI 30 min Final Session'
            AND ac.name <> 'HYPOXI Member Save Appointment'
            AND ac.name <> 'HYPOXI Phone Appointment'
            AND ac.name <> 'Massage Chair - 15 Minutes'
            AND ac.name <> 'Open Day Taster'
            AND ac.name <> 'Outreach'
            AND ac.name <> 'Personal Training 30 Minutes'
            AND ac.name <> 'Personal Training 60 Minutes'

            -- FIIT30 Strong Start -- (avoid double dash literal)
            AND ac.name NOT LIKE 'FIIT30 Strong Start%'
    )

SELECT
    c.name AS "Club",
    COUNT(DISTINCT ga.person_id) AS "Number of Members",
    COUNT(*)                     AS "Total attended classes",
    ROUND(
        CAST(COUNT(*) AS NUMERIC)
        / NULLIF(COUNT(DISTINCT ga.person_id), 0),
        2
    ) AS "Avg classes per member"
FROM gf_attendance ga
JOIN centers c
    ON c.id = ga.booking_center
GROUP BY
    c.name
ORDER BY
    c.name;

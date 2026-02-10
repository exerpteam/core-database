-- The extract is extracted from Exerp on 2026-02-08
--  
-- 2025 Wrap-Up: Complete Metrics - Visits, Classes, PT, Wellness, and Challenges by Club
-- Target Type: Other
-- Description: Shows all metrics including challenge participants in one report per club for 2025

WITH params AS (
    SELECT
        c.id AS CENTER_ID,
        c.shortname AS CENTER_NAME,
        -- Last 45 days for active member identification
        datetolongtz(TO_CHAR(CURRENT_DATE - INTERVAL '45 days', 'YYYY-MM-DD'), c.time_zone) AS LAST_45_DAYS_START,
        datetolongtz(TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD'), c.time_zone) AS TODAY,
        -- January 1, 2025 to today for visit counting
        datetolongtz('2025-01-01', c.time_zone) AS YEAR_START,
        -- January 1, 2025 to December 31, 2025 for classes
        datetolongtz('2025-12-31 23:59:59', c.time_zone) AS YEAR_END
    FROM
        centers c
    WHERE
        c.id IN (:Scope)
),
active_members_last_45_days AS (
    -- Identify members who visited in the last 45 days
    SELECT DISTINCT
        p.CENTER_ID,
        ck.person_center,
        ck.person_id
    FROM
        params p
    LEFT JOIN
        checkins ck
        ON ck.checkin_center = p.CENTER_ID
        AND ck.checkin_time BETWEEN p.LAST_45_DAYS_START AND p.TODAY
    WHERE
        ck.person_id IS NOT NULL
),
total_visits_data AS (
    -- Count all visits from Jan 1 2025 to today for those active members
    SELECT
        p.CENTER_ID,
        COUNT(ck.id) AS total_visits_ytd
    FROM
        params p
    INNER JOIN
        active_members_last_45_days am
        ON am.CENTER_ID = p.CENTER_ID
    LEFT JOIN
        checkins ck
        ON ck.checkin_center = p.CENTER_ID
        AND ck.person_center = am.person_center
        AND ck.person_id = am.person_id
        AND ck.checkin_time BETWEEN p.YEAR_START AND p.TODAY
    GROUP BY
        p.CENTER_ID
),
group_fitness_data AS (
    SELECT
        p.CENTER_ID,
        COUNT(part.id) AS gf_attended,
        COUNT(DISTINCT part.participant_id) AS gf_unique_participants,
        COUNT(DISTINCT b.id) AS gf_classes_held
    FROM
        params p
    LEFT JOIN
        bookings b
        ON b.center = p.CENTER_ID
        AND b.starttime BETWEEN p.YEAR_START AND p.YEAR_END
    LEFT JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id IN (1, 2, 3, 8, 15, 601, 7401)
        AND ac.state = 'ACTIVE'
    LEFT JOIN
        participations part
        ON part.booking_center = b.center
        AND part.booking_id = b.id
        AND part.state != 'CANCELLED'
    WHERE
        ac.id IS NOT NULL
    GROUP BY
        p.CENTER_ID
),
reformer_data AS (
    SELECT
        p.CENTER_ID,
        COUNT(part.id) AS reformer_attended,
        COUNT(DISTINCT part.participant_id) AS reformer_unique_participants
    FROM
        params p
    LEFT JOIN
        bookings b
        ON b.center = p.CENTER_ID
        AND b.starttime BETWEEN p.YEAR_START AND p.YEAR_END
    LEFT JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id IN (6, 3601, 6601)
    LEFT JOIN
        participations part
        ON part.booking_center = b.center
        AND part.booking_id = b.id
        AND part.state != 'CANCELLED'
    WHERE
        ac.id IS NOT NULL
    GROUP BY
        p.CENTER_ID
),
fiit30_data AS (
    SELECT
        p.CENTER_ID,
        COUNT(part.id) AS fiit30_attended,
        COUNT(DISTINCT part.participant_id) AS fiit30_unique_participants
    FROM
        params p
    LEFT JOIN
        bookings b
        ON b.center = p.CENTER_ID
        AND b.starttime BETWEEN p.YEAR_START AND p.YEAR_END
    LEFT JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id = 5
    LEFT JOIN
        participations part
        ON part.booking_center = b.center
        AND part.booking_id = b.id
        AND part.state != 'CANCELLED'
    WHERE
        ac.id IS NOT NULL
    GROUP BY
        p.CENTER_ID
),
pt_data AS (
    SELECT
        p.CENTER_ID,
        COUNT(part.id) AS pt_sessions_completed,
        COUNT(DISTINCT part.participant_id) AS pt_unique_clients
    FROM
        params p
    LEFT JOIN
        bookings b
        ON b.center = p.CENTER_ID
        AND b.starttime BETWEEN p.YEAR_START AND p.YEAR_END
    LEFT JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id IN (4, 6801, 201, 7201)
    LEFT JOIN
        participations part
        ON part.booking_center = b.center
        AND part.booking_id = b.id
        AND part.state != 'CANCELLED'
    WHERE
        ac.id IS NOT NULL
    GROUP BY
        p.CENTER_ID
),
sauna_massage_data AS (
    SELECT
        p.CENTER_ID,
        COUNT(part.id) AS sauna_massage_usage,
        COUNT(DISTINCT part.participant_id) AS sauna_massage_unique_users
    FROM
        params p
    LEFT JOIN
        bookings b
        ON b.center = p.CENTER_ID
        AND b.starttime BETWEEN p.YEAR_START AND p.YEAR_END
    LEFT JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id IN (4601, 8201, 4201, 402)
    LEFT JOIN
        participations part
        ON part.booking_center = b.center
        AND part.booking_id = b.id
        AND part.state != 'CANCELLED'
    WHERE
        ac.id IS NOT NULL
    GROUP BY
        p.CENTER_ID
),
strong_start_participants AS (
    SELECT
        p.CENTER_ID,
        COUNT(DISTINCT cc.owner_id) AS strong_start_count
    FROM
        params p
    LEFT JOIN
        clipcards cc
        ON cc.center = p.CENTER_ID
        AND cc.cancelled = FALSE
    LEFT JOIN
        products prod
        ON prod.center = cc.center
        AND prod.id = cc.id
    LEFT JOIN
        invoices inv
        ON inv.center = cc.invoiceline_center
        AND inv.id = cc.invoiceline_id
    WHERE
        (prod.name IN ('Strong Start 8WT - Base', 'Strong Start 8WT - FIIT30')
         OR prod.external_id IN ('STRONG_START_8WT_BASE', 'STRONG_START_8WT_FIIT30'))
        AND inv.trans_time BETWEEN p.YEAR_START AND p.YEAR_END
    GROUP BY
        p.CENTER_ID
),
winter_powerup_participants AS (
    SELECT
        p.CENTER_ID,
        COUNT(DISTINCT cc.owner_id) AS winter_powerup_count
    FROM
        params p
    LEFT JOIN
        clipcards cc
        ON cc.center = p.CENTER_ID
        AND cc.cancelled = FALSE
    LEFT JOIN
        products prod
        ON prod.center = cc.center
        AND prod.id = cc.id
    LEFT JOIN
        invoices inv
        ON inv.center = cc.invoiceline_center
        AND inv.id = cc.invoiceline_id
    WHERE
        prod.name IN ('Reformer Winter Power Up', 'FIIT30 Winter Power Up')
        AND inv.trans_time BETWEEN p.YEAR_START AND p.YEAR_END
    GROUP BY
        p.CENTER_ID
)
SELECT
    p.CENTER_NAME AS "Club Name",
    COALESCE(tv.total_visits_ytd, 0) AS "Total Visits (YTD - Active Members)",
    COALESCE(gf.gf_attended, 0) AS "Total Group Fitness Classes Attended",
    COALESCE(gf.gf_unique_participants, 0) AS "Unique Group Fitness Participants",
    COALESCE(gf.gf_classes_held, 0) AS "Total Group Fitness Classes Held",
    COALESCE(r.reformer_attended, 0) AS "Total Reformer Classes Attended",
    COALESCE(r.reformer_unique_participants, 0) AS "Unique Reformer Participants",
    COALESCE(f.fiit30_attended, 0) AS "Total FIIT30 Classes Attended",
    COALESCE(f.fiit30_unique_participants, 0) AS "Unique FIIT30 Participants",
    COALESCE(pt.pt_sessions_completed, 0) AS "Total PT Sessions Completed",
    COALESCE(pt.pt_unique_clients, 0) AS "Unique PT Clients",
    COALESCE(sm.sauna_massage_usage, 0) AS "Total Sauna/Massage Chair Usage",
    COALESCE(sm.sauna_massage_unique_users, 0) AS "Unique Sauna/Massage Users",
    COALESCE(ss.strong_start_count, 0) AS "8 Week Strong Start Challenge Participants",
    COALESCE(wp.winter_powerup_count, 0) AS "Winter Power Up Challenge Participants"
FROM
    params p
LEFT JOIN
    total_visits_data tv ON tv.CENTER_ID = p.CENTER_ID
LEFT JOIN
    group_fitness_data gf ON gf.CENTER_ID = p.CENTER_ID
LEFT JOIN
    reformer_data r ON r.CENTER_ID = p.CENTER_ID
LEFT JOIN
    fiit30_data f ON f.CENTER_ID = p.CENTER_ID
LEFT JOIN
    pt_data pt ON pt.CENTER_ID = p.CENTER_ID
LEFT JOIN
    sauna_massage_data sm ON sm.CENTER_ID = p.CENTER_ID
LEFT JOIN
    strong_start_participants ss ON ss.CENTER_ID = p.CENTER_ID
LEFT JOIN
    winter_powerup_participants wp ON wp.CENTER_ID = p.CENTER_ID
ORDER BY
    p.CENTER_NAME;

-- SETUP INSTRUCTIONS FOR EXERP:
-- 1. Go to Configuration > Reporting > Extracts
-- 2. Click "Add new extract"
-- 3. Set Target Type: "Other"
-- 4. Set Name: "2025 Wrap-Up - Complete Metrics"
-- 5. Paste the SQL above into the query box
-- 6. Add Parameter:
--    - Name: Scope
--    - Type: Scope
--    - Label: "Select Club(s)"

-- METRICS INCLUDED:
-- Total Visits: Members active in last 45 days, counting visits from Jan 1 2025 to today
-- Group Fitness: 1 (Cardio), 2 (Strength), 3 (Mind Body), 8 (Wellness), 
--                15 (Virtual Group Fitness), 601 (Bootcamp), 7401 (CLASS IN CLUB)
-- Reformer: 6 (Reformer Pilates), 3601 (Reformer Refined), 6601 (Virtual Reformer)
-- FIIT30: 5 (FIIT30 only)
-- PT Sessions: 4, 6801, 201, 7201
-- Sauna/Massage: 4601, 8201, 4201, 402
-- Strong Start Challenge: Products with external_id 'STRONG_START_8WT_BASE' or 'STRONG_START_8WT_FIIT30'
-- Winter Power Up Challenge: Products named 'Reformer Winter Power Up' or 'FIIT30 Winter Power Up'
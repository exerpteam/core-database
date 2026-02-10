-- The extract is extracted from Exerp on 2026-02-08
-- List of current members reformer subscriptions
WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE-8 AS DATE), 'YYYY-MM-dd'), c.time_zone) AS FROM_DATE,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE AS DATE), 'YYYY-MM-dd'), c.time_zone) AS TO_DATE
        FROM
            centers c
    ),
    last_visit AS
    (
    SELECT
        p.center AS person_center,
        p.id AS person_id,
        MAX(ck.checkin_time) AS last_visit_date
    FROM
        persons p
    JOIN
        checkins ck
        ON p.center = ck.person_center
        AND p.id = ck.person_id
    GROUP BY
        p.center, p.id
    ),
    visits_last_7_days AS
    (
    SELECT
        ck.person_center,
        ck.person_id,
        COUNT(*) AS visits_7_days
    FROM
        checkins ck
    JOIN
        params
    ON ck.checkin_center = params.CENTER_ID
    WHERE
        ck.checkin_time BETWEEN params.FROM_DATE AND params.TO_DATE
    GROUP BY
        ck.person_center, ck.person_id
    ),
    latest_subscription_price AS (
        SELECT
            sp.subscription_center,
            sp.subscription_id,
            sp.price,
            ROW_NUMBER() OVER (
                PARTITION BY sp.subscription_center, sp.subscription_id
                ORDER BY sp.from_date DESC
            ) AS rn
        FROM
            subscription_price sp
        WHERE
            sp.cancelled IS FALSE
    )
SELECT
    p.center || 'p' || p.id AS "Person ID",  -- Person ID
    p.external_id AS "External ID",  -- External ID
    s.center || 'ss' || s.id AS "Subscription ID",  -- Subscription ID
    c.shortname AS "Centre",  -- Centre
    CASE
        WHEN p.status = 1 THEN 'Active' 
        WHEN p.status = 3 THEN 'Temporary Inactive'
        ELSE ''
    END AS "Person Status",  -- Person Status
    CASE
        WHEN p.persontype = 0 THEN 'Private'
        WHEN p.persontype = 1 THEN 'Student'
        WHEN p.persontype = 2 THEN 'Staff'  -- Staff included
        WHEN p.persontype = 3 THEN 'Friend'
        WHEN p.persontype = 4 THEN 'Corporate'
        WHEN p.persontype = 5 THEN 'One Man Corporate'
        WHEN p.persontype = 6 THEN 'Family'
        WHEN p.persontype = 7 THEN 'Senior'
        WHEN p.persontype = 8 THEN 'Guest'
        WHEN p.persontype = 9 THEN 'Child'
        WHEN p.persontype = 10 THEN 'External Staff' 
        ELSE 'Unknown'
    END AS "Person Type",  -- Person Type
    p.firstname AS "First Name",  -- First Name
    p.lastname AS "Last Name",  -- Last Name
    prod.NAME AS "Subscription Name",  -- Subscription Name
    lsp.price AS "Subscription Price",  -- Latest Subscription Price
    s.start_date AS "Subscription Start Date",  -- Subscription Start Date
    s.end_date AS "Subscription End Date",  -- Subscription End Date
    s.binding_end_date AS "Binding End Date",  -- Binding End Date
    TO_CHAR(TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours', 'DD-MM-YYYY') AS "Last Visit Date",  -- Last Visit Date with time adjustment and formatted as DD-MM-YYYY
    COALESCE(visits_last_7_days.visits_7_days, 0) AS "Visits in Last 7 Days",  -- Visits in Last 7 Days
    COALESCE(CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date, 0) AS "Days Since Last Visit",  -- Days Since Last Visit
    COUNT(ck.id) AS "Total Number of Visits",  -- Total Number of Visits
    p.first_active_start_date AS "First Active Start Date",  -- First Active Start Date moved to the end
    p.last_active_start_date AS "Last Active Start Date"  -- Last Active Start Date moved to the end
FROM 
    persons p 
JOIN
    subscriptions s
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
    ON prod.center = st.center
    AND prod.id = st.id
LEFT JOIN
    latest_subscription_price lsp  -- Use only the latest price
    ON lsp.subscription_center = s.center
    AND lsp.subscription_id = s.id
    AND lsp.rn = 1  -- Only pick the latest price
LEFT JOIN
    checkins ck
    ON p.center = ck.person_center
    AND p.id = ck.person_id
JOIN
    centers c
    ON c.id = p.center
LEFT JOIN
    last_visit
    ON p.center = last_visit.person_center
    AND p.id = last_visit.person_id
LEFT JOIN
    visits_last_7_days
    ON p.center = visits_last_7_days.person_center
    AND p.id = visits_last_7_days.person_id
WHERE
    s.state NOT IN (3, 7, 8)  -- Exclude subscriptions with states 'ended' (3), 'window' (7), and 'created' (8)
    AND s.sub_state NOT IN (4, 6, 8)  -- Exclude subscriptions with sub-states 'downgraded' (4), 'transferred' (6), and 'cancelled' (8)
    AND p.center IN (:Scope)
    AND prod.NAME NOT IN (
       '12 Month Ongoing',
		'6 Month Ongoing',
		'Fernwood 12 Month Ongoing',
		'12 Month Complimentary Staff',
		'Personal Training Sessions',
		'Flexi Membership',
		'Fernwood 6 Month Ongoing',
		'FIIT30 Membership 12 Months',
		'1 Month Complimentary Membership',
		'6 Month PIF',
'Simple Starter Membership - 12-Month Ongoing',
'Fernwood Flexible Membership',
'HYPOXI Transform 12 Weeks Upgrade + HDC',
'Fernwood 18 Month Ongoing',
'HYPOXI Fine Tune 4 Week Ongoing Upgrade',
'12 Month Fixed Term',
'HYPOXI Fine Tune 4 Week Ongoing Membership',
'HYPOXI Fine Tune 4 Week Membership + HDC',
'HYPOXI Transform 12 Weeks Ongoing Membership',
'6 Week Trial',
'HYPOXI 12 Week Maintenance',
'3 Month PIF ',
'FIIT30 Flexi PIF Members',
'HYPOXI Transform 12 Weeks Ongoing Upgrade',
'HYPOXI Revolution 26 Weeks Ongoing Membership',
'3 Month Ongoing',
'FIIT30 Membership Flexi',
'FIIT30 Membership 3 Months',
'12 Month PIF',
'6 Month Fixed Term',
'12 Month Complimentary',
'HYPOXI 4 Week Maintenance',
'FIIT30 Results 12 Month Ongoing Membership',
'Personal Training Sessions (6 Months)',
'Exercise Physiologists Sessions - 30 mins',
'14 Day Trial',
'6 Month Complimentary',
'7 Day Trial ',
'3 Month Complimentary',
'Exercise Physiologists Sessions - 60 mins',
'18 Month Ongoing',
'One Month Membership',
'Fusion 12 Month Complimentary',
'Fusion Complimentary Staff',
'FIIT30 Membership 18 Months',
'Fernwood 12 Month FIIT30 Membership ',
'HDC 4 Week Membership',
'FIITMAX Membership 12 Months',
'Wellness Membership 12 Month',
'Wellness Membership Flexi',
'FIITMAX Membership 3 Months',
'HYPOXI 12 Weeks Membership + HDC',
'FIITMAXI Flexi PIF Members',
'3 Month FIIT30 Membership - 2 Sessions',
'FIITMAX Membership Flexi',
'FIIT30 Membership 3 Month PIF',
'HYPOXI 4 Week Upgrade + HDC',
'﻿Fernwood Pulse Program',
'Wellness Membership 18 Month',
'Wellness Membership 3 Month',
'Fernwood 3 Month Ongoing Membership ',
'Fernwood 12 Month Ongoing Membership ',
'HYPOXI Maintenance Ongoing',
'Personal Training Membership',
'FIIT30 Membership 6 Month',
'HYPOXI 4 Week Ongoing',
'Fernwood 18 Month Ongoing Membership',
'Unlimited Childcare Access',
'FIIT30 Sessions',
'18 Month Platinum',
'Fernwood 3 Month Ongoing',
'HDC 12 Week Membership',
'HYPOXI Revolution 26 Weeks Ongoing Upgrade',
'HDC 8 Week Membership',
'Personal Training 45 Minute Sessions',
'HYPOXI 8 Week Ongoing Membership',
'Personal Training Sessions (12 Months)',
'5 Day Pass',
'HYPOXI Revolution 26 Weeks Upgrade + HDC ',
'HDC Flexi Upgrade 3 Sessions',
'HYPOXI 4 Week Maintenance + HDC',
'8 Week Trial',
'One Month Trial',
'HYPOXI 6 Week Ongoing Membership',
'FIIT30 Membership 12 Week Commitment',
'Personal Training Sessions (3 Months)',
'Fire & Ice - 2 Sessions',
'Recovery Lounge - 2 Sessions',
'Recovery Lounge Sessions',
'Fire & Ice Sessions',
'FIIT30 Membership 12 Month PIF',
'12 Week Commitment Platinum',
'Recovery Lounge Upgrade',
'$10 for 10 Days',
'FIIT30 Only Membership Flexi',
'3 Day Trial ',
'1 Day Trial ',
'Fernwood 12 Month Ongoing.',
'HYPOXI HDC Upgrade',
'HYPOXI Maintenance + HDC',
'Sauna Sessions - 6 Month Min Term',
'12 Month Renewal PIF',
'Sauna Sessions - 12 Week Min Term',
'Sauna Sessions - 6 Week Min Term',
'Nutrition Coaching Sessions',
'Master Personal Training Sessions',
'Personal Training 45 Min Sessions',
'Personal Training 60 Minute Sessions',
'$20 for 20 Days',
'HYPOXI Maintenance',
'Childcare Flexi PIF Members',
'$7 for 7 Days',
'HYPOXI Flexi Membership',
'12 Month FIIT30 Membership - 3 Sessions',
'HYPOXI 3 Month 6 Sessions per week Membership',
'HYPOXI 6 Month 6 Sessions per week Membership',
'HYPOXI Flexible 6 Session per week Membership',
'HYPOXI 3 Month 3 Sessions per week Membership',
'HYPOXI 6 Week 6 Sessions per week',
'HYPOXI 6 Week 3 Sessions per week',
'HYPOXI Flexible 3 Session per week Membership',
'HYPOXI 6 Month 3 Sessions per week Membership',
'HDC 3 Month Membership',
'3 Month Fixed Term',
'Fernwood 6 Month FIIT30 Membership ',
'HYPOXI HDC Upgrade - Member',
'HYPOXI HDC Upgrade Non-Member',
'3 Month FIIT30 Membership - 1 Session',
'12 Month Complimentary Reformer',
'Fernwood 12 Months Paid In Full',
'3 Month Work Cover Membership PIF',
'6 Month Work Cover Membership PIF',
'12 Month Results Membership',
'Fernwood 12 Month Fixed Term',
'Exercise Physiologists Sessions 60 mins',
'15 Month Ongoing',
'Sauna Sessions',
'Wellness Membership 6 Month',
'Outdoor Bootcamp',
'FIIT30+ Comp Access',
'26 Week Trial',
'12 Week Trial',
'FIIT30+ Membership 12 Month',
'4 Week Trial',
'FIIT30+ Membership 18 Months',
'1 Month PIF ',
'HYPOXI 26 Week Maintenance',
'18 Month Fixed Term',
'WHF $30 for 30 Days',
'Personal Training - 2 Sessions',
'$14 for 14 Days',
'Get It All 14 Days',
'HDC 26 Week Membership',
'4 Week Membership',
'Pulse 30 Day Pass',
'28 Day Trial ',
'6 Week Teen Holiday Membership',
'8 Week Teen Holiday Membership',
'Premium Locker PIF Members',
'Student Membership',
'Fire & Ice - 4 Sessions',
'Fernwood 12 Month FIIT30 Membership',
'8WT Participant 24/7 Access',
'Complimentary Recovery Access',
'Recovery Sessions',
'Personal Training Membership ',
'3 Week Trial',
'12 Month Uni Student',
'12 Week Semi Private Pilates PT - 1 Session',
'Buddy PT Sessions',
'3 Month FT - Student',
'HYPOXI Sessions',
'HDC Sessions',
'Easter 2 Week Teen Membership',
		'12 Month Basic Access',
        'FIIT30 Membership 6 Months'
    )
    AND p.persontype != 2  -- Exclude staff
GROUP BY
    p.center,
    p.id,
    p.external_id,
    c.shortname,
    p.firstname,
    p.lastname,
    prod.NAME,
    lsp.price,  -- Group by latest price
    s.start_date,
    s.end_date,
    s.binding_end_date,
    s.center,
    s.id,
    last_visit.last_visit_date,
    visits_last_7_days.visits_7_days,
    p.first_active_start_date,
    p.last_active_start_date
ORDER BY 
    p.center, p.lastname, p.firstname;

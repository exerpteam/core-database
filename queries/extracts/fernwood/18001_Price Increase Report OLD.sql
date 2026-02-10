-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    active_members AS
    (
    SELECT
        p.center || 'p' || p.id AS person_id,
        p.center,  -- Include this in SELECT to match with GROUP BY
        p.external_id,
        CASE
            WHEN p.persontype = 0 THEN 'Private'
            WHEN p.persontype = 1 THEN 'Student'
            WHEN p.persontype = 2 THEN 'Staff'
            WHEN p.persontype = 3 THEN 'Friend'
            WHEN p.persontype = 4 THEN 'Corporate'
            WHEN p.persontype = 5 THEN 'One Man Corporate'
            WHEN p.persontype = 6 THEN 'Family'
            WHEN p.persontype = 7 THEN 'Senior'
            WHEN p.persontype = 8 THEN 'Guest'
            WHEN p.persontype = 9 THEN 'Child'
            WHEN p.persontype = 10 THEN 'External Staff' 
            ELSE 'Unknown'
        END AS person_type,
        s.center || 'ss' || s.id AS subscription_id,  -- Format Subscription ID with center number and 'ss' prefix
        p.firstname,
        p.lastname,
        EXTRACT(YEAR FROM AGE(p.birthdate)) AS age,  -- Calculate age from birthdate
        prod.NAME AS subscription_name,
        sp.price AS subscription_price,
        s.start_date AS subscription_start_date,
        s.end_date AS subscription_end_date,  -- Add Subscription End Date
        s.binding_end_date AS binding_end_date,
        sp.from_date AS last_price_adjustment_date,  -- Most recent price adjustment date
        MAX(ck.checkin_time) AS last_active_date,
        COUNT(CASE 
                WHEN TO_TIMESTAMP(ck.checkin_time / 1000) >= CURRENT_DATE - INTERVAL '90 days' 
                THEN 1 
                ELSE NULL 
            END) AS visits_last_90_days,
        COUNT(CASE 
                WHEN TO_TIMESTAMP(ck.checkin_time / 1000) >= CURRENT_DATE - INTERVAL '60 days' 
                THEN 1 
                ELSE NULL 
            END) AS visits_last_60_days,
        ROW_NUMBER() OVER (PARTITION BY s.center, s.id ORDER BY sp.from_date DESC) AS rn  -- Row number to filter the latest adjustment
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
        subscription_price sp
        ON sp.subscription_center = s.center
        AND sp.subscription_id = s.id
        AND sp.cancelled IS FALSE
    LEFT JOIN
        checkins ck
        ON p.center = ck.person_center
        AND p.id = ck.person_id
    WHERE 
        p.status = 1  -- Active members only
        AND p.persontype != 2  -- Exclude staff
        AND (s.end_date IS NULL OR s.end_date > CURRENT_DATE)  -- Exclude ended subscriptions
        AND prod.NAME NOT IN (
            'Unlimited Childcare Access', 
            '12 Month PIF'  -- Ensure the subscription names are properly closed with quotes
        )  -- Exclude specific subscriptions
        AND p.center = :Centre::int  -- Filter by selected center/location
        AND (s.binding_end_date <= CURRENT_DATE + INTERVAL '30 days' OR s.binding_end_date < CURRENT_DATE)  -- Keep subscriptions with binding end date in 30 days or already passed
    GROUP BY 
        p.center, p.id, p.external_id, p.persontype, s.center, s.id, p.firstname, p.lastname, 
        prod.NAME, sp.price, s.start_date, s.end_date, s.binding_end_date, sp.from_date, p.birthdate
    HAVING
        TO_TIMESTAMP(MAX(ck.checkin_time) / 1000) >= CURRENT_DATE - INTERVAL '90 days'  -- Exclude subscriptions where the last active date is 90 days in the past
    )
SELECT 
    person_id AS "Person ID",
    external_id AS "External ID",
    person_type AS "Person Type",
    subscription_id AS "Subscription ID",
    firstname AS "First Name",
    lastname AS "Last Name",
    age AS "Age",  -- Add age column after Last Name
    subscription_name AS "Subscription Name",
    subscription_price AS "Subscription Price",
    TO_CHAR(subscription_start_date, 'DD-MM-YYYY') AS "Subscription Start Date",
    TO_CHAR(subscription_end_date, 'DD-MM-YYYY') AS "Subscription End Date",  -- Subscription End Date added
    TO_CHAR(binding_end_date, 'DD-MM-YYYY') AS "Binding End Date",
    TO_CHAR(last_price_adjustment_date, 'DD-MM-YYYY') AS "Last Price Adjustment Date",  -- Last Price Adjustment Date formatted
    TO_CHAR(TO_TIMESTAMP(last_active_date / 1000), 'DD-MM-YYYY') AS "Last Visit Date",
    visits_last_90_days AS "Number of Visits Last 90 Days",
    visits_last_60_days AS "Number of Visits Last 60 Days"  -- New column for visits in the last 60 days
FROM 
    active_members
WHERE rn = 1  -- Only take the most recent price adjustment
ORDER BY 
    lastname, firstname;
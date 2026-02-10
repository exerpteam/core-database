-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
active_members AS (
    SELECT
        p.center || 'p' || p.id AS person_id,
        p.center,
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
        CASE 
            WHEN p.status = 1 THEN 'Active'
            WHEN p.status = 3 THEN 'Frozen'
            ELSE 'Unknown'
        END AS subscription_status,
        s.center || 'ss' || s.id AS subscription_id,
        p.firstname,
        p.lastname,
        EXTRACT(YEAR FROM AGE(p.birthdate)) AS age,
        prod.NAME AS subscription_name,
        sp.price AS subscription_price,
        sp.from_date AS price_effective_date,
        LEAD(sp.from_date) OVER (PARTITION BY s.center, s.id ORDER BY sp.from_date) AS price_end_date,
        (LEAD(sp.from_date) OVER (PARTITION BY s.center, s.id ORDER BY sp.from_date) - sp.from_date) AS price_duration_days,
        s.start_date AS subscription_start_date,
        s.end_date AS subscription_end_date,
        s.binding_end_date AS binding_end_date,
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
            END) AS visits_last_60_days
    FROM 
        persons p
    JOIN
        subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
    JOIN
        subscriptiontypes st ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id
    JOIN
        products prod ON prod.center = st.center AND prod.id = st.id
    LEFT JOIN
        subscription_price sp ON sp.subscription_center = s.center AND sp.subscription_id = s.id AND sp.cancelled IS FALSE
    LEFT JOIN
        checkins ck ON p.center = ck.person_center AND p.id = ck.person_id
    WHERE 
        p.status IN (1, 3)
        AND p.persontype != 2
        AND prod.NAME NOT IN (
            'Unlimited Childcare Access', 
            '12 Month PIF',
            '12 Month Complimentary Staff', 
            '14 Day Trial', 
            '7 Day Trial', 
            '3 Month Complimentary', 
            '5 Day Pass', 
            '6 Month Complimentary',
            '3 Month PIF',
            '12 Month Complimentary',
            '8 Week Trial',
            '6 Month PIF',
            '$10 for 10 Days',
            '1 Month PIF ',
            '3 Month PIF ',
            '7 Day Trial '
        )
        AND p.center IN (:Centres)
    GROUP BY 
        p.center, p.id, p.external_id, p.persontype, p.status, s.center, s.id, p.firstname, p.lastname, 
        prod.NAME, sp.price, sp.from_date, s.start_date, s.end_date, s.binding_end_date, p.birthdate
),
member_addons AS (
    SELECT
        s.owner_center || 'p' || s.owner_id AS person_id,
        s.center || 'ss' || s.id AS subscription_id,
        prod_addon.name AS addon_name,
        sao.start_date AS addon_start_date,
        sao.end_date AS addon_end_date,
        sao.individual_price_per_unit AS addon_price
    FROM
        subscription_addon sao
    JOIN
        subscriptions s ON s.center = sao.subscription_center AND s.id = sao.subscription_id
    JOIN
        masterproductregister mpr_addon ON mpr_addon.id = sao.addon_product_id
    JOIN
        products prod_addon ON prod_addon.center = sao.center_id AND prod_addon.globalid = mpr_addon.globalid
    WHERE
        sao.cancelled != 'true' 
        AND (sao.end_date IS NULL OR sao.end_date > CURRENT_DATE)
)
SELECT 
    am.person_id AS "Person ID",
    am.external_id AS "External ID",
    am.person_type AS "Person Type",
    am.subscription_status AS "Subscription Status",
    am.subscription_id AS "Subscription ID",
    am.firstname AS "First Name",
    am.lastname AS "Last Name",
    am.age AS "Age",
    am.subscription_name AS "Subscription Name",
    am.subscription_price AS "Subscription Price",
    TO_CHAR(am.price_effective_date, 'DD-MM-YYYY') AS "Price Effective Date",
    TO_CHAR(am.price_end_date, 'DD-MM-YYYY') AS "Price End Date",
    am.price_duration_days AS "Days at This Price",
    TO_CHAR(am.subscription_start_date, 'DD-MM-YYYY') AS "Subscription Start Date",
    TO_CHAR(am.subscription_end_date, 'DD-MM-YYYY') AS "Subscription End Date",
    TO_CHAR(am.binding_end_date, 'DD-MM-YYYY') AS "Binding End Date",
    GREATEST(0, am.binding_end_date - CURRENT_DATE) AS "Days until outside binding end date",
    TO_CHAR(TO_TIMESTAMP(am.last_active_date / 1000), 'DD-MM-YYYY') AS "Last Visit Date",
    am.visits_last_90_days AS "Number of Visits Last 90 Days",
    am.visits_last_60_days AS "Number of Visits Last 60 Days",
    CASE 
        WHEN am.visits_last_90_days > 0 THEN 'Yes'
        ELSE 'No'
    END AS "Member Visited Last 90 Days",
    ma.addon_name AS "Add-on Name",
    TO_CHAR(ma.addon_start_date, 'DD-MM-YYYY') AS "Add-on Start Date",
    TO_CHAR(ma.addon_end_date, 'DD-MM-YYYY') AS "Add-on End Date",
    ma.addon_price AS "Add-on Price"
FROM 
    active_members am
LEFT JOIN 
    member_addons ma ON am.person_id = ma.person_id AND am.subscription_id = ma.subscription_id
ORDER BY
    am.person_id, am.price_effective_date;
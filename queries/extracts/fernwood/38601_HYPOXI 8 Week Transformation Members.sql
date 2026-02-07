-- HYPOXI 8 WEEK SUBSCRIPTION & CLIPCARD EXTRACT
-- Returns members currently on any of the specified HYPOXI 8 Week subscriptions OR clipcards
-- Includes cancellation date if applicable

WITH 
    jemax AS
    (
        -- Get the latest journal entry for cancellation requests (jetype = 18)
        SELECT 
            person_center, 
            person_id, 
            ref_center, 
            ref_id, 
            MAX(id) AS JournalID
        FROM 
            journalentries 
        WHERE 
            jetype = 18
        GROUP BY 
            person_center, person_id, ref_center, ref_id
    )

-- SUBSCRIPTIONS (3 ongoing/upgrade products)
SELECT 
    p.center || 'p' || p.id AS "Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    c.shortname AS "Club",
    prod.NAME AS "Subscription/Product Name",
    s.binding_end_date AS "Binding End Date",
    CASE 
        WHEN s.sub_state = 8 THEN CAST(longtodatec(je.creation_time, je.person_center) AS date)
        ELSE NULL
    END AS "Cancellation Date",
    'Subscription' AS "Product Type"

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

JOIN 
    centers c
    ON c.id = p.center

LEFT JOIN
    jemax
    ON jemax.person_center = s.owner_center
    AND jemax.person_id = s.owner_id
    AND jemax.ref_center = s.center
    AND jemax.ref_id = s.id

LEFT JOIN 
    journalentries je
    ON jemax.JournalID = je.id

WHERE 
    s.state IN (2, 4, 8)  -- 2 = ACTIVE, 4 = FROZEN, 8 = CREATED
    AND p.status IN (1, 3)  -- 1 = Active, 3 = Temporarily Inactive
    AND p.center IN (:Scope)
    AND prod.NAME IN (
        'HYPOXI 8WT 8 Week HDC Ongoing Upgrade',
        'HYPOXI 8WT 8 Week Ongoing Membership',
        'HYPOXI 8WT 8 Week+ HDC Ongoing Membership'
    )

UNION ALL

-- CLIPCARDS (2 PIF products)
SELECT 
    p.center || 'p' || p.id AS "Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    c.shortname AS "Club",
    prod.NAME AS "Subscription/Product Name",
    NULL AS "Binding End Date",  -- Clipcards don't have binding end dates
    NULL AS "Cancellation Date",  -- Clipcards have different cancellation handling
    'Clip Card' AS "Product Type"

FROM 
    persons p

JOIN
    clipcards cc
    ON p.center = cc.owner_center
    AND p.id = cc.owner_id

JOIN
    products prod
    ON prod.center = cc.center
    AND prod.id = cc.id

JOIN 
    centers c
    ON c.id = p.center

WHERE 
    cc.cancelled IS FALSE
    AND cc.blocked IS FALSE
    AND p.status IN (1, 3)  -- 1 = Active, 3 = Temporarily Inactive
    AND p.center IN (:Scope)
    AND prod.NAME IN (
        'HYPOXI 8WT 8 Week + HDC PIF',
        'HYPOXI 8WT 8 Week PIF'
    )

ORDER BY 
    "Club", "Last Name", "First Name";

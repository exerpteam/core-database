-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    p.center ||'p'|| p.id AS "Person ID",
    p.firstname AS "Lead First Name",
    p.lastname AS "Lead Last Name",
    'Squad Goals Referral Program' AS "Campaign Source Name",
    referrer_ext_id.txtvalue AS "Referrer External ID",
    COALESCE(referrer_person.firstname || ' ' || referrer_person.lastname, '') AS "Referred by",
    CASE 
        WHEN trial_subs.person_id IS NOT NULL THEN 'Y' 
        ELSE 'N' 
    END AS "Had Trial",
    CASE 
        WHEN paid_subs.person_id IS NOT NULL THEN 'Y' 
        ELSE 'N' 
    END AS "Lead Converted to Sale",
    CASE
        WHEN p.status=0 THEN 'Lead'
        WHEN p.status=1 THEN 'Active'
        WHEN p.status=2 THEN 'Inactive'
        WHEN p.status=3 THEN 'Temporary Inactive'
        WHEN p.status=4 THEN 'Transferred'
        WHEN p.status=5 THEN 'Duplicate'
        WHEN p.status=6 THEN 'Prospect'
        WHEN p.status=7 THEN 'Deleted'
        WHEN p.status=8 THEN 'Anonymized'
        WHEN p.status=9 THEN 'Contact'
        ELSE 'Undefined'
    END AS "Person Status"
FROM 
    persons p
-- MUST have Referrer External ID to be included (using correct attribute ID)
JOIN 
    person_ext_attrs referrer_ext_id
    ON referrer_ext_id.personcenter = p.center
    AND referrer_ext_id.personid = p.id
    AND referrer_ext_id.name = 'ReferrersExternalID'
    AND referrer_ext_id.txtvalue IS NOT NULL
    AND referrer_ext_id.txtvalue != ''
-- Find the referrer person based on external ID
LEFT JOIN 
    persons referrer_person
    ON referrer_person.external_id = referrer_ext_id.txtvalue
    AND referrer_person.center = p.center
-- Check if person had any trial subscription
LEFT JOIN (
    SELECT DISTINCT
        s.owner_center,
        s.owner_id,
        s.owner_id as person_id
    FROM subscriptions s
    JOIN products prod
        ON prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id
    WHERE s.state NOT IN (5, 7, 8) 
        AND (LOWER(prod.name) LIKE '%trial%' 
             OR LOWER(prod.name) LIKE '%7 day%'
             OR LOWER(prod.name) LIKE '%14 day%'
             OR LOWER(prod.name) LIKE '%free%'
             OR LOWER(prod.name) LIKE '%pass%')
) trial_subs
    ON trial_subs.owner_center = p.center
    AND trial_subs.owner_id = p.id
-- Check if person has any paid subscription (excluding trials and comps)
LEFT JOIN (
    SELECT DISTINCT
        s.owner_center,
        s.owner_id,
        s.owner_id as person_id
    FROM subscriptions s
    JOIN products prod
        ON prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id
    WHERE s.state IN (2, 4) -- Active or Frozen
        AND NOT (LOWER(prod.name) LIKE '%trial%' 
                 OR LOWER(prod.name) LIKE '%comp%'
                 OR LOWER(prod.name) LIKE '%free%'
                 OR LOWER(prod.name) LIKE '%pass%'
                 OR LOWER(prod.name) LIKE '%day%')
        AND prod.name NOT IN ('Squad Goals Referral Program')
) paid_subs
    ON paid_subs.owner_center = p.center
    AND paid_subs.owner_id = p.id
WHERE 
    p.center IN (:Scope)
ORDER BY 
    p.lastname, p.firstname
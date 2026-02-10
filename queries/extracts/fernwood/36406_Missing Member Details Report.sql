-- The extract is extracted from Exerp on 2026-02-08
-- This report identifies ACTIVE members with incomplete or missing profile information including: Email address, mobile phone, physical address, emergency contact details & email/SMS preferences. Ability to filter by all, New members (joined in the past 90 days) or Existing members (90 days or older). Excludes staff person types. 
-- Missing Member Details Report
-- This report identifies active members with missing required information
-- Author: Based on Exerp database structure
-- Purpose: Help franchisees identify and follow up on incomplete member profiles
-- Parameters: 
--   :Scope - Center/club selection
--   :MemberType - Filter by 'New', 'Existing', or 'All'

SELECT 
    c.shortname AS "Club Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    CASE
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'
        ELSE 'Other'
    END AS "Person Status",
    
    -- Member Classification (New vs Existing)
    CASE
        WHEN p.first_active_start_date >= (CURRENT_DATE - INTERVAL '90 days') THEN 'New'
        ELSE 'Existing'
    END AS "Member Type",
    
    -- Membership Details
    prod.name AS "Membership Type",
    COALESCE(sp.price, 0) AS "Weekly DD Amount",
    
    -- Contact Details Checks
    CASE WHEN peaEmail.txtvalue IS NULL OR TRIM(peaEmail.txtvalue) = '' THEN 'MISSING' ELSE 'OK' END AS "Email Status",
    peaEmail.txtvalue AS "Email Address",
    
    CASE WHEN peaMobile.txtvalue IS NULL OR TRIM(peaMobile.txtvalue) = '' THEN 'MISSING' ELSE 'OK' END AS "Mobile Status",
    peaMobile.txtvalue AS "Mobile Number",
    

    
    -- Physical Address Check
    CASE 
        WHEN (p.address1 IS NULL OR TRIM(p.address1) = '') 
             AND (p.city IS NULL OR TRIM(p.city) = '') 
             AND (p.zipcode IS NULL OR TRIM(p.zipcode) = '') 
        THEN 'MISSING' 
        ELSE 'OK' 
    END AS "Address Status",
    p.address1 AS "Address",
    p.city AS "Suburb",
    p.zipcode AS "Post Code",
    
    -- Emergency Contact Check
    CASE WHEN peaEmergencyName.txtvalue IS NULL OR TRIM(peaEmergencyName.txtvalue) = '' THEN 'MISSING' ELSE 'OK' END AS "Emergency Contact Status",
    peaEmergencyName.txtvalue AS "Emergency Contact Name",
    peaEmergencyPhone.txtvalue AS "Emergency Contact Phone",
    
    -- Payment Agreement Check (via payment_accounts and payment_agreements)
    CASE WHEN pag.id IS NULL THEN 'MISSING' ELSE 'OK' END AS "Payment Agreement Status",
    
    -- Marketing Preferences Check
    CASE 
        WHEN AllowEmail.txtvalue = 'false' THEN 'OPTED OUT'
        WHEN AllowEmail.txtvalue IS NULL THEN 'NOT SET'
        WHEN AllowEmail.txtvalue = 'true' THEN 'OPTED IN'
        ELSE 'UNKNOWN'
    END AS "Email Marketing Status",
    
    CASE 
        WHEN AllowSMS.txtvalue = 'false' THEN 'OPTED OUT'
        WHEN AllowSMS.txtvalue IS NULL THEN 'NOT SET'  
        WHEN AllowSMS.txtvalue = 'true' THEN 'OPTED IN'
        ELSE 'UNKNOWN'
    END AS "SMS Marketing Status",
    
    -- Summary of Missing Items
    CONCAT_WS(', ',
        CASE WHEN peaEmail.txtvalue IS NULL OR TRIM(peaEmail.txtvalue) = '' THEN 'Email' END,
        CASE WHEN peaMobile.txtvalue IS NULL OR TRIM(peaMobile.txtvalue) = '' THEN 'Mobile' END,

        CASE WHEN (p.address1 IS NULL OR TRIM(p.address1) = '') 
                  AND (p.city IS NULL OR TRIM(p.city) = '') 
                  AND (p.zipcode IS NULL OR TRIM(p.zipcode) = '') 
             THEN 'Address' END,
        CASE WHEN peaEmergencyName.txtvalue IS NULL OR TRIM(peaEmergencyName.txtvalue) = '' THEN 'Emergency Contact' END,
        CASE WHEN pag.id IS NULL THEN 'Payment Agreement' END,
        CASE WHEN AllowEmail.txtvalue = 'false' OR AllowEmail.txtvalue IS NULL THEN 'Email Opt-in' END,
        CASE WHEN AllowSMS.txtvalue = 'false' OR AllowSMS.txtvalue IS NULL THEN 'SMS Opt-in' END
    ) AS "Missing Details",
    
    -- Count of missing items for sorting/filtering
    (CASE WHEN peaEmail.txtvalue IS NULL OR TRIM(peaEmail.txtvalue) = '' THEN 1 ELSE 0 END +
     CASE WHEN peaMobile.txtvalue IS NULL OR TRIM(peaMobile.txtvalue) = '' THEN 1 ELSE 0 END +
     CASE WHEN (p.address1 IS NULL OR TRIM(p.address1) = '') 
               AND (p.city IS NULL OR TRIM(p.city) = '') 
               AND (p.zipcode IS NULL OR TRIM(p.zipcode) = '') 
          THEN 1 ELSE 0 END +
     CASE WHEN peaEmergencyName.txtvalue IS NULL OR TRIM(peaEmergencyName.txtvalue) = '' THEN 1 ELSE 0 END +
     CASE WHEN pag.id IS NULL THEN 1 ELSE 0 END +
     CASE WHEN AllowEmail.txtvalue = 'false' OR AllowEmail.txtvalue IS NULL THEN 1 ELSE 0 END +
     CASE WHEN AllowSMS.txtvalue = 'false' OR AllowSMS.txtvalue IS NULL THEN 1 ELSE 0 END
    ) AS "Missing Count"

FROM 
    persons p
JOIN
    centers c ON c.id = p.center
-- Only include members with active subscriptions
JOIN
    subscriptions s ON s.owner_center = p.center 
                   AND s.owner_id = p.id
                   AND s.state IN (2, 4) -- Active and Frozen subscriptions
-- Email
LEFT JOIN
    person_ext_attrs peaEmail ON peaEmail.personcenter = p.center
                              AND peaEmail.personid = p.id
                              AND peaEmail.name = '_eClub_Email'
-- Mobile Phone
LEFT JOIN
    person_ext_attrs peaMobile ON peaMobile.personcenter = p.center
                               AND peaMobile.personid = p.id
                               AND peaMobile.name = '_eClub_PhoneSMS'

-- Emergency Contact Name
LEFT JOIN
    person_ext_attrs peaEmergencyName ON peaEmergencyName.personcenter = p.center
                                       AND peaEmergencyName.personid = p.id
                                       AND peaEmergencyName.name = 'EmergencyContactName'
-- Emergency Contact Phone
LEFT JOIN
    person_ext_attrs peaEmergencyPhone ON peaEmergencyPhone.personcenter = p.center
                                        AND peaEmergencyPhone.personid = p.id
                                        AND peaEmergencyPhone.name = 'EmergencyContactNumber'
-- Payment Agreement Check (Active Payment Agreements)
LEFT JOIN 
    account_receivables ar ON ar.customercenter = p.center 
                           AND ar.customerid = p.id 
                           AND ar.ar_type = 4   
LEFT JOIN 
    payment_accounts pac ON pac.center = ar.center 
                         AND pac.id = ar.id
LEFT JOIN 
    payment_agreements pag ON pac.active_agr_center = pag.center 
                           AND pac.active_agr_id = pag.id 
                           AND pac.active_agr_subid = pag.subid
-- Email Marketing Preferences
LEFT JOIN
    person_ext_attrs AllowEmail ON AllowEmail.personcenter = p.center
                                AND AllowEmail.personid = p.id
                                AND AllowEmail.name = '_eClub_AllowedChannelEmail'
-- SMS Marketing Preferences  
LEFT JOIN
    person_ext_attrs AllowSMS ON AllowSMS.personcenter = p.center
                              AND AllowSMS.personid = p.id
                              AND AllowSMS.name = '_eClub_AllowedChannelSMS'
-- Active Subscription and Product Details
LEFT JOIN
    (
        SELECT DISTINCT
            s.owner_center,
            s.owner_id,
            s.subscriptiontype_center,
            s.subscriptiontype_id,
            ROW_NUMBER() OVER (PARTITION BY s.owner_center, s.owner_id ORDER BY s.start_date DESC) as rn
        FROM subscriptions s
        WHERE s.state IN (2, 4) -- Active and Frozen subscriptions
    ) active_sub ON active_sub.owner_center = p.center
                 AND active_sub.owner_id = p.id
                 AND active_sub.rn = 1 -- Get most recent active subscription
-- Product/Membership Type
LEFT JOIN
    products prod ON prod.center = active_sub.subscriptiontype_center
                  AND prod.id = active_sub.subscriptiontype_id
-- Current Subscription Price
LEFT JOIN
    (
        SELECT 
            sp.subscription_center,
            sp.subscription_id,
            sp.price,
            ROW_NUMBER() OVER (PARTITION BY sp.subscription_center, sp.subscription_id ORDER BY sp.from_date DESC) as rn
        FROM subscription_price sp
        WHERE sp.cancelled = FALSE
    ) sp ON sp.subscription_center = active_sub.owner_center
         AND sp.subscription_id = (
             SELECT s2.id 
             FROM subscriptions s2 
             WHERE s2.owner_center = active_sub.owner_center 
               AND s2.owner_id = active_sub.owner_id
               AND s2.subscriptiontype_center = active_sub.subscriptiontype_center
               AND s2.subscriptiontype_id = active_sub.subscriptiontype_id
               AND s2.state IN (2, 4)
             ORDER BY s2.start_date DESC 
             LIMIT 1
         )
         AND sp.rn = 1 -- Get most recent price

WHERE
    p.center IN (:Scope) -- This will be replaced with actual center IDs
    AND p.status IN (1, 3) -- Active and Temporary Inactive members only
    AND p.persontype != 6 -- Exclude family members if needed
    AND p.persontype != 2 -- Exclude staff members
    -- Member Type Filter Parameter
    AND (
        :MemberType = 'All' OR
        (:MemberType = 'New' AND p.first_active_start_date >= (CURRENT_DATE - INTERVAL '90 days')) OR
        (:MemberType = 'Existing' AND p.first_active_start_date < (CURRENT_DATE - INTERVAL '90 days'))
    )
    -- Only show members with at least one missing detail
    AND (
        peaEmail.txtvalue IS NULL OR TRIM(peaEmail.txtvalue) = '' OR
        peaMobile.txtvalue IS NULL OR TRIM(peaMobile.txtvalue) = '' OR
        (
            (p.address1 IS NULL OR TRIM(p.address1) = '') AND
            (p.city IS NULL OR TRIM(p.city) = '') AND
            (p.zipcode IS NULL OR TRIM(p.zipcode) = '')
        ) OR
        peaEmergencyName.txtvalue IS NULL OR TRIM(peaEmergencyName.txtvalue) = '' OR
        pag.id IS NULL OR
        AllowEmail.txtvalue = 'false' OR AllowEmail.txtvalue IS NULL OR
        AllowSMS.txtvalue = 'false' OR AllowSMS.txtvalue IS NULL
    )

ORDER BY 
    "Missing Count" DESC, -- Show members with most missing details first
    c.shortname,
    p.lastname, 
    p.firstname;
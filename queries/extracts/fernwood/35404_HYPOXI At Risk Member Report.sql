-- The extract is extracted from Exerp on 2026-02-08
-- Active HYPOXI members who have not visited in the last 5 days and have no future bookings.
WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE-5 AS DATE), 'YYYY-MM-dd'), c.time_zone) AS FIVE_DAYS_AGO,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE AS DATE), 'YYYY-MM-dd'), c.time_zone) AS TODAY,
            FLOOR(extract(epoch from now())*1000) AS CURRENT_TIMESTAMP
        FROM
            centers c
    ),
    -- Get active HYPOXI members
    active_hypoxi_members AS (
        SELECT DISTINCT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            c.shortname AS centre_name,
            prod.NAME AS subscription_name,
            peeaEmail.txtvalue AS email_address,
            peeaMobile.txtvalue AS mobile_number,
            peeaHome.txtvalue AS home_phone,
            s.start_date AS subscription_start_date,
            s.end_date AS subscription_end_date
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
            person_ext_attrs peeaEmail
            ON peeaEmail.personcenter = p.center
            AND peeaEmail.personid = p.id
            AND peeaEmail.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs peeaMobile
            ON peeaMobile.personcenter = p.center
            AND peeaMobile.personid = p.id
            AND peeaMobile.name = '_eClub_PhoneSMS' 
        LEFT JOIN
            person_ext_attrs peeaHome
            ON peeaHome.personcenter = p.center
            AND peeaHome.personid = p.id
            AND peeaHome.name = '_eClub_PhoneHome'
        WHERE
            s.state NOT IN (3, 7, 8)  -- Exclude ended, window, created states
            AND s.sub_state NOT IN (4, 6, 8)  -- Exclude downgraded, transferred, cancelled
            AND p.center IN (:Scope)
            AND p.status IN (1, 3)  -- Active and Temporary Inactive
            AND p.persontype != 2  -- Exclude staff
            -- Filter for HYPOXI products only
            AND UPPER(prod.NAME) LIKE '%HYPOXI%'
    ),
    -- Check for recent HYPOXI bookings (last 5 days)
    recent_hypoxi_activity AS (
        SELECT DISTINCT
            part.participant_center,
            part.participant_id
        FROM    
            participations part
        JOIN    
            bookings b
            ON b.center = part.booking_center
            AND b.id = part.booking_id
        JOIN 
            activity ac
            ON b.activity = ac.id  
        JOIN 
            activity_group acg
            ON acg.id = ac.activity_group_id
        JOIN
            params 
            ON params.CENTER_ID = part.booking_center              
        WHERE 
            part.participant_center IN (:Scope)
            AND b.starttime BETWEEN params.FIVE_DAYS_AGO AND params.TODAY
            AND UPPER(acg.name) LIKE '%HYPOXI%'
            AND part.state != 'CANCELLED'
    ),
    -- Check for future HYPOXI bookings
    future_hypoxi_bookings AS (
        SELECT DISTINCT
            part.participant_center,
            part.participant_id,
            MIN(b.starttime) AS next_booking_time
        FROM    
            participations part
        JOIN    
            bookings b
            ON b.center = part.booking_center
            AND b.id = part.booking_id
        JOIN 
            activity ac
            ON b.activity = ac.id  
        JOIN 
            activity_group acg
            ON acg.id = ac.activity_group_id
        JOIN
            params 
            ON params.CENTER_ID = part.booking_center              
        WHERE 
            part.participant_center IN (:Scope)
            AND b.starttime > params.CURRENT_TIMESTAMP
            AND UPPER(acg.name) LIKE '%HYPOXI%'
            AND part.state != 'CANCELLED'
        GROUP BY
            part.participant_center,
            part.participant_id
    )

-- Main query: Get HYPOXI members with no recent activity and no future bookings
SELECT
    ahm.center || 'p' || ahm.id AS "Person ID",
    ahm.external_id AS "External ID",
    ahm.centre_name AS "Centre",
    ahm.firstname AS "First Name",
    ahm.lastname AS "Last Name",
    ahm.subscription_name AS "HYPOXI Subscription",
    ahm.email_address AS "Email Address",
    ahm.mobile_number AS "Mobile Number",
    ahm.home_phone AS "Home Phone",
    ahm.subscription_start_date AS "Subscription Start Date",
    ahm.subscription_end_date AS "Subscription End Date",
    CASE 
        WHEN rha.participant_id IS NOT NULL THEN 'Yes' 
        ELSE 'No' 
    END AS "Had Recent Activity (Last 5 Days)",
    CASE 
        WHEN fhb.participant_id IS NOT NULL THEN 'Yes' 
        ELSE 'No' 
    END AS "Has Future Bookings",
    TO_CHAR(TO_TIMESTAMP(fhb.next_booking_time / 1000), 'DD-MM-YYYY HH24:MI') AS "Next Booking Date/Time"
FROM
    active_hypoxi_members ahm
LEFT JOIN
    recent_hypoxi_activity rha
    ON ahm.center = rha.participant_center
    AND ahm.id = rha.participant_id
LEFT JOIN
    future_hypoxi_bookings fhb
    ON ahm.center = fhb.participant_center
    AND ahm.id = fhb.participant_id
WHERE
    -- Members with NO recent activity AND NO future bookings
    rha.participant_id IS NULL
    AND fhb.participant_id IS NULL
ORDER BY 
    ahm.centre_name, ahm.lastname, ahm.firstname;
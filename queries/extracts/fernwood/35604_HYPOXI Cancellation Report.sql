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
    jemax AS
    (
        SELECT 
            person_center, person_id, ref_center, ref_id, max(id) AS JournalID
        FROM 
            fernwood.journalentries 
        WHERE 
            jetype = 18
        GROUP BY 
            person_center, person_id, ref_center, ref_id
    ),
    a AS
    (
        SELECT max(start_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID 
        FROM 
            fernwood.attends   
        GROUP BY 
            person_center, person_id
    ),
    -- Check for recent HYPOXI bookings (last 5 days) - matching At Risk logic
    recent_hypoxi_activity AS (
        SELECT DISTINCT
            part.participant_center,
            part.participant_id
        FROM    
            fernwood.participations part
        JOIN    
            fernwood.bookings b
            ON b.center = part.booking_center
            AND b.id = part.booking_id
        JOIN 
            fernwood.activity ac
            ON b.activity = ac.id  
        JOIN 
            fernwood.activity_group acg
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
    -- Check for future HYPOXI bookings - matching At Risk logic
    future_hypoxi_bookings AS (
        SELECT DISTINCT
            part.participant_center,
            part.participant_id,
            MIN(b.starttime) AS next_booking_time
        FROM    
            fernwood.participations part
        JOIN    
            fernwood.bookings b
            ON b.center = part.booking_center
            AND b.id = part.booking_id
        JOIN 
            fernwood.activity ac
            ON b.activity = ac.id  
        JOIN 
            fernwood.activity_group acg
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
SELECT 
    c.shortname AS "Center Name", -- 1
    p.center || 'p' || p.id AS "Person ID", -- 2
    p.external_id AS "External ID", -- 3
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
    END AS "Person Status", -- 4
    p.firstname AS "First Name", -- 5
    p.lastname AS "Last Name", -- 6
    prod.NAME AS "HYPOXI Subscription", -- 7
    peeaEmail.txtvalue AS "Email Address", -- 8
    peeaMobile.txtvalue AS "Mobile Number", -- 9
    peeaHome.txtvalue AS "Home Phone", -- 10
    s.start_date AS "Subscription Start Date", -- 11
    s.end_date AS "Subscription End Date", -- 12
    ep.fullname AS "Operator", -- 13
    emp.center || 'emp' || emp.id AS "Employee ID", -- 14
    CAST(longtodatec(je.creation_time, je.person_center) AS date) AS "Cancellation Requested Date", -- 15
    TO_CHAR(TO_TIMESTAMP(a.LastVisitDate / 1000), 'DD-MM-YYYY') AS "Last Visit Date", -- 16
    s.subscription_price AS "Subscription Price", -- 17
    s.binding_end_date AS "Binding End Date", -- 18
    CASE 
        WHEN rha.participant_id IS NOT NULL THEN 'Yes' 
        ELSE 'No' 
    END AS "Had Recent Activity (Last 5 Days)", -- 19
    CASE 
        WHEN fhb.participant_id IS NOT NULL THEN 'Yes' 
        ELSE 'No' 
    END AS "Has Future Bookings", -- 20
    TO_CHAR(TO_TIMESTAMP(fhb.next_booking_time / 1000), 'DD-MM-YYYY HH24:MI') AS "Next Booking Date/Time", -- 21
    CASE 
        -- Calculate (Binding End Date - Cancelled Date)
        WHEN (s.binding_end_date - s.end_date) > 0
        THEN ROUND(
            (s.binding_end_date - s.end_date) * (s.subscription_price / 14), 2
        )
        -- If the result is <= 0, return 0
        ELSE 0
    END AS "De-Gross" -- 22
FROM 
    fernwood.subscriptions s
JOIN
    fernwood.persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    fernwood.subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
LEFT JOIN
    jemax
    ON jemax.person_center = s.owner_center
    AND jemax.person_id = s.owner_id
    AND jemax.ref_center = s.center
    AND jemax.ref_id = s.id
LEFT JOIN 
    fernwood.journalentries je
    ON jemax.JournalID = je.id
LEFT JOIN
    fernwood.employees emp
    ON emp.center = je.creatorcenter
    AND emp.ID = je.creatorid
LEFT JOIN
    fernwood.persons ep
    ON ep.center = emp.personcenter
    AND ep.ID = emp.personid    
JOIN
    fernwood.products prod
    ON prod.CENTER = st.CENTER
    AND prod.ID = st.ID
JOIN 
    fernwood.centers c
    ON c.id = p.center
LEFT JOIN 
    fernwood.person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
LEFT JOIN 
    fernwood.person_ext_attrs peeaMobile
    ON peeaMobile.personcenter = p.center
    AND peeaMobile.personid = p.id
    AND peeaMobile.name = '_eClub_PhoneSMS' 
LEFT JOIN 
    fernwood.person_ext_attrs peeaHome
    ON peeaHome.personcenter = p.center
    AND peeaHome.personid = p.id
    AND peeaHome.name = '_eClub_PhoneHome'
LEFT JOIN
    a
    ON a.PersonCenter = p.center
    AND a.PersonID = p.ID
LEFT JOIN
    recent_hypoxi_activity rha
    ON p.center = rha.participant_center
    AND p.id = rha.participant_id
LEFT JOIN
    future_hypoxi_bookings fhb
    ON p.center = fhb.participant_center
    AND p.id = fhb.participant_id     
WHERE 
    s.end_date IS NOT NULL
    AND s.end_date BETWEEN :From AND :To
    AND p.center IN (:Scope)
    AND UPPER(prod.NAME) LIKE '%HYPOXI%'  -- Using same HYPOXI filter as At Risk report
    AND s.sub_state NOT IN (3, 4, 5, 10)
ORDER BY 
    c.shortname, p.lastname, p.firstname
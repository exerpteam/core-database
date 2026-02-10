-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
    jemax AS
    (
        SELECT 
            person_center, person_id, ref_center, ref_id, max(id) AS JournalID
        FROM 
            journalentries 
        WHERE 
            jetype = 18
        GROUP BY 
            person_center, person_id, ref_center, ref_id
    ),
    a AS
    (
        SELECT max(start_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID 
        FROM 
            attends   
        GROUP BY 
            person_center, person_id
    )                      
SELECT 
    c.shortname AS "Center Name", -- 1
    p.center || 'p' || p.id AS "Person ID", -- 2
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
    END AS "Person Status", -- 3
    p.firstname AS "First Name", -- 4
    p.lastname AS "Last Name", -- 5
    peeaEmail.txtvalue AS "Email", -- 6
    peeaMobile.txtvalue AS "Mobile", -- 7
    peeaHome.txtvalue AS "Home", -- 8
    ep.fullname AS "Operator", -- 9
    emp.center || 'emp' || emp.id AS "Employee ID", -- 10
    CAST(longtodatec(je.creation_time, je.person_center) AS date) AS "Cancellation Requested Date", -- 11
TO_CHAR(TO_TIMESTAMP(a.LastVisitDate / 1000), 'DD-MM-YYYY') AS "Last Visit Date", -- 12
    prod.NAME AS "Subscription Name", -- 13
    s.subscription_price AS "Subscription Price", -- 14
    s.end_date AS "Effective Cancellation Date",  -- 15
    s.binding_end_date AS "Binding End Date",  -- 16
    CASE 
        -- Calculate (Binding End Date - Cancelled Date)
        WHEN (s.binding_end_date - s.end_date) > 0
        THEN ROUND(
            (s.binding_end_date - s.end_date) * (s.subscription_price / 14), 2
        )
        -- If the result is <= 0, return 0
        ELSE 0
    END AS "De-Gross" -- 17
FROM 
    subscriptions s
JOIN
    persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
LEFT JOIN
    jemax
    ON jemax.person_center = s.owner_center
    AND jemax.person_id = s.owner_id
    AND jemax.ref_center = s.center
    AND jemax.ref_id = s.id
LEFT JOIN 
    journalentries je
    ON jemax.JournalID = je.id
LEFT JOIN
    employees emp
    ON emp.center = je.creatorcenter
    AND emp.ID = je.creatorid
LEFT JOIN
    persons ep
    ON ep.center = emp.personcenter
    AND ep.ID = emp.personid    
JOIN
    PRODUCTS prod
    ON prod.CENTER = st.CENTER
    AND prod.ID = st.ID
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
LEFT JOIN
    a
    ON a.PersonCenter = p.center
    AND a.PersonID = p.ID     
WHERE 
    s.end_date IS NOT NULL
    AND s.end_date BETWEEN :From AND :To
    AND p.center IN (:Scope)
    AND prod.center || 'prod' || prod.id NOT IN 
        (SELECT pg.product_center || 'prod' || pg.product_id AS ID 
         FROM product_and_product_group_link pg 
         WHERE pg.product_group_id = 402)
    AND s.sub_state NOT IN (3, 4, 5, 10)

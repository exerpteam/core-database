-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
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
    TO_CHAR(TO_TIMESTAMP(a.LastVisitDate / 1000), 'DD-MM-YYYY') AS "Last Visit Date", -- 8
    prod.NAME AS "Subscription Name", -- 9
    s.end_date AS "Effective Cancellation Date"  -- 10
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
    a
    ON a.PersonCenter = p.center
    AND a.PersonID = p.ID     
WHERE 
    s.end_date IS NOT NULL
    AND s.end_date BETWEEN :From AND :To
    AND p.center IN (:Scope)
    AND p.status = 2  -- Only Inactive status
    AND prod.center || 'prod' || prod.id NOT IN 
        (SELECT pg.product_center || 'prod' || pg.product_id AS ID 
         FROM product_and_product_group_link pg 
         WHERE pg.product_group_id = 402)
    AND s.sub_state NOT IN (3, 4, 5, 10)
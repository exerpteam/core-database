-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-13019
WITH active_subscriptions AS
        (
        SELECT 
                prod.name
                ,s.owner_center
                ,s.owner_id
                ,s.start_date         
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN
                products prod
                ON prod.center = st.center
                AND prod.id = st.id
                AND prod.primary_product_group_id NOT IN (237)
        WHERE
                s.state IN (2,4)
                AND
                s.center IN (:scope)
        )                
SELECT DISTINCT 
        p.fullname AS "Member Name"
        ,p.CENTER || 'p' || p.ID AS "Person ID"
        ,Mobile.txtvalue AS "Mobile"
        ,email.txtvalue AS "Email"
        ,prod.NAME AS "Subscription Name"
        ,longtodateC(s.CREATION_TIME,s.center) AS "Trial Load Date"
        ,s.START_DATE AS "Trial Start Date"
        ,s.end_date AS "Trial End Date"
        ,CASE
                WHEN s.state = 2 THEN 'Active'
                WHEN s.state = 3 THEN 'Ended'
                WHEN s.state = 4 THEN 'Frozen'
                WHEN s.state = 7 THEN 'Window'
                WHEN s.state = 8 THEN 'Created'
                ELSE 'Unknown'
         END AS "Subscription Status"
         ,actives.name AS "Membership Sold"
         ,actives.start_date AS "Membership Start Date" 
         ,longtodateC(la.LastVisitDate,la.PersonCenter) AS "Last Visit Date"
         ,visits.totalvisit AS "Total Number of Visits"
         ,inv.GrossValue AS "Trial Gross Value"
FROM
        SUBSCRIPTIONS s
JOIN
        CENTERS c
        ON c.id = s.center
JOIN
        SUBSCRIPTIONTYPES st
        ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
        PRODUCTS prod
        ON prod.CENTER = st.CENTER
        AND prod.ID = st.ID
        AND prod.primary_product_group_id IN (237)
JOIN
        PERSONS p
        ON p.CENTER = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
LEFT JOIN 
        person_ext_attrs email
        ON email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email' 
LEFT JOIN
        person_ext_attrs Mobile
        ON Mobile.personcenter = p.center
        AND Mobile.personid = p.id
        AND Mobile.name = '_eClub_PhoneSMS'  
LEFT JOIN
        active_subscriptions actives
        ON actives.owner_center = s.owner_center
        AND actives.owner_id = s.owner_id
        AND actives.start_date > longtodateC(s.CREATION_TIME,s.center) 
LEFT JOIN
        (SELECT 
                max(checkin_time) AS LastVisitDate
                ,person_center AS PersonCenter
                ,person_id AS PersonID             
        FROM 
                checkins 
        GROUP BY 
                person_center
                ,person_id
        ) la
        ON la.PersonCenter = p.center
        AND la.PersonID = p.id 
LEFT JOIN
        (
        SELECT 
                COUNT(checkin_time) AS totalvisit
                ,person_center AS PersonCenter
                ,person_id AS PersonID             
        FROM 
                checkins 
        GROUP BY 
                person_center
                ,person_id
        )visits
        ON visits.PersonCenter = p.center
        AND visits.PersonID = p.id 
LEFT JOIN
        (
        SELECT
                sum(inl.total_amount) AS GrossValue
                ,inl.center
                ,inl.id 
        FROM 
                invoice_lines_mt inl 
        GROUP BY
                inl.center
                ,inl.id   
        )inv
        ON inv.center = s.invoiceline_center
        AND inv.id = s.invoiceline_id                                                        
WHERE 
        s.center in (:scope)
        AND
        s.CREATION_TIME between 
                GETSTARTOFDAY(CAST (CAST (:StartDate AS DATE) AS TEXT),s.CENTER)
                AND GETENDOFDAY(CAST (CAST (:EndDate AS DATE) AS TEXT), s.CENTER)
        
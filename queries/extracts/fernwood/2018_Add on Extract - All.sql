-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-1901
SELECT  
        s.owner_center||'p'||s.owner_id AS "PersonID"
        ,p.external_id AS "ExternalID"
        ,CASE
                p.persontype
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 3 THEN 'Friend'
                WHEN 4 THEN 'Corporate'
                WHEN 5 THEN 'One Man Corporate'
                WHEN 6 THEN 'Family'
                WHEN 7 THEN 'Senior'
                WHEN 8 THEN 'Guest'
                WHEN 9 THEN 'Child'
                WHEN 10 THEN 'External Staff' 
        END AS "Person type" 
        ,p.fullname AS "Full Name"
        ,c.shortname AS "Center" 
        ,prod_addon.name AS "Addon Name"
        ,peeaEmail.txtvalue AS "Email"
        ,peeaMobile.txtvalue AS "Mobile"
        ,peeaHome.txtvalue AS "Home"
        ,sao.start_date AS "Start Date"
        ,sao.end_date AS "End Date"
        ,CASE
                WHEN sao.cancelled != 'true' AND sao.end_date < current_date then 'Ended'
                WHEN sao.cancelled = 'true' then 'Deleted'
                Else 'Active' 
        END AS "Status"
        ,sao.individual_price_per_unit AS "Add on Price"
	,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
FROM 
        subscriptions s
JOIN 
        persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN
        centers c
        ON c.id = s.center        
JOIN 
        subscription_addon sao 
        ON sao.subscription_center = s.center 
        AND sao.subscription_id = s.id
JOIN  
        MASTERPRODUCTREGISTER mpr_addon 
        ON mpr_addon.id = sao.ADDON_PRODUCT_ID
JOIN 
        PRODUCTS prod_addon
        ON prod_addon.center = sao.CENTER_ID
        AND prod_addon.GLOBALID = mpr_addon.GLOBALID
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
        (SELECT max(checkin_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID             
        FROM checkins 
        GROUP BY person_center,person_id ) la
        ON la.PersonCenter = p.center
        AND la.PersonID = p.id
WHERE 
	s.center in (:Scope)
ORDER BY 1 

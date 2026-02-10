-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-9882
SELECT
        p.firstname AS "First Name"
        ,p.lastname As "Surname"
        ,externalID.txtvalue AS "External ID (Membership ID)"
        ,(CAST(longtodatec(a.LastVisitDate,a.PersonCenter) as date)) AS "Last Visit Date"
        ,(current_date - (CAST(longtodatec(a.LastVisitDate,a.PersonCenter) as date))) AS "Days Since Last Visit"
        ,Mobile.txtvalue AS "Mobile Number"
        ,Home.txtvalue AS "Home Phone"
		,peeaEmail.txtvalue AS "Email"
        ,pro.name AS "Subscription Name (Membership Type)"
FROM 
        persons p
JOIN
        subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id 
        AND s.state in (2,4)
JOIN
        (SELECT max(checkin_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID             
        FROM checkins 
        GROUP BY person_center,person_id ) a
        ON a.PersonCenter = p.center
        AND a.PersonID = p.id
LEFT JOIN
        person_ext_attrs externalID
        ON externalID.personcenter = p.center
        AND externalID.personid = p.id
        AND externalID.name = '_eClub_OldSystemPersonId'
LEFT JOIN
        person_ext_attrs Mobile
        ON Mobile.personcenter = p.center
        AND Mobile.personid = p.id
        AND Mobile.name = '_eClub_PhoneSMS'        
LEFT JOIN
        person_ext_attrs Home
        ON Home.personcenter = p.center
        AND Home.personid = p.id
        AND Home.name = '_eClub_PhoneHome'
LEFT JOIN 
        person_ext_attrs peeaEmail
        ON peeaEmail.personcenter = p.center
        AND peeaEmail.personid = p.id
        AND peeaEmail.name = '_eClub_Email'
JOIN
        products pro
        ON pro.center = s.SUBSCRIPTIONTYPE_CENTER
        AND pro.ID = s.SUBSCRIPTIONTYPE_ID              
WHERE
        (current_date - (CAST(longtodatec(a.LastVisitDate,a.PersonCenter) as date))) = :NumberOfDays
        AND 
        p.center in (:Scope)
        AND
        p.persontype != 6 
                

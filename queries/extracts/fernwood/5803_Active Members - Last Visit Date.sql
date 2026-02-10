-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT DISTINCT
        p.firstname AS "First Name"
        ,p.lastname As "Surname"
		,p.center ||'p'|| p .id AS "Person ID"
        ,p.external_id AS "External ID"
        ,p.birthdate AS "Date of Birth"
        ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
        ,(current_date - (CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date))) AS "Days Since Last Visit"
        ,Mobile.txtvalue AS "Mobile Number"
        ,Home.txtvalue AS "Home Phone"
        ,Email.txtvalue AS "Email Address"
        ,pro.name AS "Subscription Name (Membership Type)"
FROM 
        persons p
JOIN
        subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id 
        AND s.state in (2,4)
JOIN
        checkins a
        ON a.person_center = p.center
        AND a.person_id = p.id
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
JOIN
        products pro
        ON pro.center = s.SUBSCRIPTIONTYPE_CENTER
        AND pro.ID = s.SUBSCRIPTIONTYPE_ID
JOIN 
        params 
        ON params.CENTER_ID = p.center 
JOIN
        (SELECT max(checkin_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID             
        FROM checkins 
        GROUP BY person_center,person_id ) la
        ON la.PersonCenter = p.center
        AND la.PersonID = p.id 
LEFT JOIN
        person_ext_attrs email
        ON email.personcenter = p.center
        AND email.personid = p.id 
        AND email.name = '_eClub_Email'                                       
WHERE
        a.checkin_time BETWEEN params.FromDate AND params.ToDate
        AND 
        p.center in (:Scope)
        AND
        p.persontype != 6
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
SELECT
        c.shortname AS "Club Name"
        ,p.external_id AS "External ID"
        ,p.center ||'p'|| p.id AS "Person ID"
        ,p.fullname AS "Member Full Name"
        ,peaMobile.txtvalue AS "Contact Number"
        ,peaEmail.txtvalue AS "Email"
        ,peaPostcode.txtvalue AS "Postcode"
        ,CASE p.status
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS "Person Status"
        ,LeadSource.txtvalue AS "Lead Source"
        ,b.name AS "Activity Booked"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-dd HH24:MI') AS "Appointment Date"
        ,CASE part.state
                WHEN 'BOOKED' THEN 'Booked'
                WHEN 'CANCELLED' THEN 'Cancelled'
                WHEN 'PARTICIPATION' THEN 'Attended'
                WHEN 'REVIEW' THEN 'Review'
                WHEN 'TENTATIVE' THEN 'Tentative'
        END AS "Appointment Status"
        ,sub.name AS "Subscription Name"                 
FROM
        participations part
JOIN 
        persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN 
        bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN
        centers c
        ON c.id = p.center
JOIN
        activity ac
        ON ac.id = b.activity
        AND ac.activity_group_id = 2601 -- Sales Activity Group               
LEFT JOIN
        person_ext_attrs peaMobile
        ON peaMobile.personcenter = p.center
        AND peaMobile.personid = p.id
        AND peaMobile.name = '_eClub_PhoneSMS'
LEFT JOIN
        person_ext_attrs peaEmail
        ON peaEmail.personcenter = p.center
        AND peaEmail.personid = p.id
        AND peaEmail.name = '_eClub_Email'
LEFT JOIN
        person_ext_attrs peaPostcode
        ON peaPostcode.personcenter = p.center
        AND peaPostcode.personid = p.id
        AND peaPostcode.name = '_eClub_Postcode'
LEFT JOIN
        person_ext_attrs LeadSource
        ON LeadSource.personcenter = p.center
        AND LeadSource.personid = p.id
        AND LeadSource
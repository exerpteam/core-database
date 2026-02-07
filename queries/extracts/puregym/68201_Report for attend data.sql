 SELECT
   CASE
         WHEN p.external_id is null
         THEN p2.external_id
         ELSE p.external_id
     END AS "Member External ID"
   , to_char(longtodatetz(ci.CHECKIN_TIME,'Europe/London'), 'DD/MM/YYYY HH24:MI') AS "Attendance Time stamp"
   , c.name AS "Centre Name Attended"
   , floor(months_between(current_timestamp, P.BIRTHDATE) / 12) as Age
   , p.sex
   , p.fullname as "Member Full Name"
   , CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
   , c2.name as "home center"
   , pea_mobile.txtvalue AS "Member Phone"
   , pea_email.txtvalue  AS "Email Address"
 FROM
     PERSONS p
 join
 CHECKINS ci
 on
 ci.PERSON_CENTER = p.center
 AND ci.PERSON_ID = p.id
 JOIN
     CENTERS c
 ON
     c.id = ci.CHECKIN_CENTER
 left join
 centers c2
 on
 c2.id = p.center
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.PERSONCENTER = p.center
     AND pea_email.PERSONID = p.id
     AND pea_email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS pea_mobile
 ON
     pea_mobile.PERSONCENTER = p.center
     AND pea_mobile.PERSONID = p.id
     AND pea_mobile.NAME = '_eClub_PhoneSMS'
 left join
 persons p2
 on
 p.TRANSFERS_CURRENT_PRS_CENTER = p2.center
 and
 p.TRANSFERS_CURRENT_PRS_id = p2.id
 WHERE
     ci.CHECKIN_CENTER in (:scope)
 and
 ci.CHECKIN_TIME between (:fromdate) and (:todate + 86400000)

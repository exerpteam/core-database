-- The extract is extracted from Exerp on 2026-02-08
-- Members Attendences History
 SELECT
     p.center || 'p' || p.id                                              AS MemberID ,
     TO_CHAR(longtodateTZ(c.checkin_time, cn.time_zone), 'DD/MM/YYYY') AS "ENTERDATE" ,
     c.checkin_center                                                     AS Attend_Center_id ,
     cn.name                                                              AS Attend_Center_Name ,
     TO_CHAR(longtodateTZ(c.checkin_time, cn.time_zone), 'HH24:MI:SS') AS "ENTERTIME" ,
     extract(DAY FROM 24*60*(longtodateTZ(c.checkout_time, cn.time_zone) - longtodateTZ
     (c.checkin_time, cn.time_zone))) AS "DURATION",
 cn.Time_zone "Timezone"
 FROM
     persons p
 JOIN
     checkins c
 ON
     p.center = c.person_center
 AND p.id = c.person_id
 JOIN
     centers cn
 ON
     c.checkin_center = cn.id
 WHERE
     (p.current_person_center,p.current_person_id) IN (:MemberId)

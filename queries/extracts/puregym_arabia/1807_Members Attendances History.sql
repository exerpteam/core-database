-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id                                              AS MemberID ,
    TO_CHAR(longtodatec(c.checkin_time, c.checkin_center), 'DD/MM/YYYY') AS "ENTERDATE" ,
    c.checkin_center                                                     AS Attend_Center_id ,
    cn.name                                                              AS Attend_Center_Name ,
    TO_CHAR(longtodatec(c.checkin_time, c.checkin_center), 'HH24:MI:SS') AS "ENTERTIME" ,
    extract(DAY FROM 24*60*(longtodatec(c.checkout_time, c.checkin_center) - longtodatec
    (c.checkin_time, c.checkin_center))) AS "DURATION"
from persons p
join checkins c
on p.center = c.person_center
and p.id = c.person_id
join centers cn
on c.checkin_center = cn.id
WHERE
(p.transfers_current_prs_center,p.transfers_current_prs_id) in (:MemberId)
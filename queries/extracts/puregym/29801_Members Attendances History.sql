-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-12304
select 
    p.center || 'p' || p.id as MemberID
  , to_char(longtodateTZ(c.checkin_time, 'Europe/London'), 'DD/MM/YYYY') as "ENTERDATE"
  , c.checkin_center as Attend_Center_id
  , cn.name as Attend_Center_Name
  , to_char(longtodateTZ(c.checkin_time, 'Europe/London'), 'HH24:MI:SS') as "ENTERTIME"
  , extract(day from 24*60*(longtodateTZ(c.checkout_time, 'Europe/London') - longtodateTZ(c.checkin_time, 'Europe/London'))) as "DURATION"
from persons p
join checkins c
on p.center = c.person_center
and p.id = c.person_id
join centers cn
on c.checkin_center = cn.id
WHERE
(p.transfers_current_prs_center,p.transfers_current_prs_id) in (:MemberId)
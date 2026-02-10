-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct 
t1.Member_ID as "Member ID",
t1.fullname as "Members Name",
cast(t1.age as integer) as "Age",
t1.Length_of_membership as "Length of membership",
t1.productname as "Subs Type",
t1.CENTERNAME as scope,
t1.name as "Class Name",
t1.Start_Time_of_Class as "Start Time of Class",
t1.Date_of_Class as "Date of Class",
to_char(date(t1.Date_of_Class), 'Day') as "Weekday of Class",
t1.Activity_Group_of_Class as "Activity Group of Class",
t1.Instructor as "Instructor"


from (


select distinct
par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS Member_ID,
p.fullname,
par.CENTER AS CLUB,
c.NAME AS CENTERNAME,
b.name,
to_char (longtodate(par.creation_time), 'dd-MM-YYYY HH24:MI') AS CREATIONTIME,
to_char (longtodatetz(b.starttime,'Europe/London'), 'HH24:MI') AS Start_Time_of_Class,
to_char (longtodatetz(b.starttime,'Europe/London'),  'YYYY-MM-DD') AS Date_of_Class,
--par.PARTICIPATION_NUMBER AS SEAT_NUMBER,
--par.ON_WAITING_LIST AS ON_WAITINGLIST,
staff.fullname as Instructor,
ag.name as Activity_Group_of_Class,
par.STATE AS BOOKINGSTATE,
b.center,
pro.name as productname,
b.id,
TRUNC(CURRENT_TIMESTAMP) - p.LAST_ACTIVE_START_DATE + 1  as Length_of_membership,
floor(months_between(current_timestamp, p.BIRTHDATE) / 12) as age,
CASE WHEN st.ST_TYPE = 0 THEN 'Cash' WHEN ST_TYPE = 1 THEN 'EFT' WHEN ST_TYPE = 2 THEN 'Clipcard' WHEN ST_TYPE = 3 THEN 'Course' END AS Subs_Type

from participations par
join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
join centers c
on b.center = c.ID
JOIN
     ACTIVITY ac
 ON
     ac.ID = b.ACTIVITY
    
 JOIN
     ACTIVITY_GROUP ag
 ON
     ag.ID = ac.activity_group_id
join persons p
on
par.PARTICIPANT_CENTER = p.center and
par.PARTICIPANT_ID = p.id
left join staff_usage su
on b.center = su.booking_center and b.id = su.booking_id
and su.state != 'CANCELLED'
left join persons staff
on su.person_center = staff.center AND su.person_id = staff.id
left join EMPLOYEES e 
ON staff.CENTER = e.PERSONCENTER AND staff.ID = e.PERSONID
left join subscriptions s
on
s.owner_center = p.center
and
s.owner_id = p.id
left join subscriptiontypes st
on
s.subscriptiontype_center = st.center
and
s.subscriptiontype_id = st.id
left join products pro
  on
     st.center = pro.center
     and st.id = pro.id

where
b.CENTER in (:scope)
--b.STATE = 'ACTIVE'
AND par.state != 'CANCELLED'
and s.state = 2
AND b.starttime >= :fromdate
and b.starttime <= :todate
and ag.id in (:activity_group) )t1
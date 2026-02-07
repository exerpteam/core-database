select bk.center as BOOKING_CENTER, bk.id as BOOKING_ID, bk.owner_center as PERSON_CENTER, bk.owner_id as PERSON_ID, 
bk.center || 'bk' || bk.id as BookingId
--, count(*) 
,
to_char(longtodateC(bk.starttime, bk.center),'YYYY-MM-DD HH24:MI') as BookingStartTime, 
to_char(longtodateC(bk.stoptime, bk.center),'YYYY-MM-DD HH24:MI') as BookingEndTime, 
to_char(longtodateC(bk.creation_time, bk.center),'YYYY-MM-DD HH24:MI') as BookingCreationTime, 
to_char(longtodateC(bk.last_modified, bk.center),'YYYY-MM-DD HH24:MI') as BookingModifiedTime,
ac.id as ActivityId,
ac.name as ActivityName,
bk.name as BookingName,
(select TO_CHAR(longtodateC(min(ci.checkin_time), bk.center),'YYYY-MM-DD') from goodlife.checkins ci where ci.person_center =  bk.owner_center and ci.person_id = bk.owner_id 
and ci.checkin_time >= datetolongC(to_char(longtodateC(bk.starttime, bk.center),'YYYY-MM-DD 00:00'), bk.center)
and ci.checkin_time < datetolongC(to_char(longtodateC(bk.starttime, bk.center),'YYYY-MM-DD 00:00'), bk.center) + 24*3600*1000
) as FirstSameDayCheckIn

, bk.owner_center || 'p' || bk.owner_id as MemberId
, su.person_center || 'p' || su.person_id as StaffId 
, su.Id as StaffUsageId
--, cli.center || 'cc' || cli.id || 'id' || cli.subid as ClipcardId
--, clip_pdt.center || 'pd' || clip_pdt.id as ClipcardProductId
--, clip_pdt.name as ClipcardProductName
--, bk.*


from bookings bk
join goodlife.activity ac on ac.id = bk.activity
--left join bookings dependant_bk on bk.center = dependant_bk.main_booking_center and bk.id = dependant_bk.main_booking_id
--join goodlife.participations main_part on main_part.booking_center = main_bk.center and main_part.booking_id = main_bk.id 
left join goodlife.participations part on part.booking_center = bk.center and part.booking_id = bk.id
left join goodlife.staff_usage su on su.booking_center = bk.center and su.booking_id = bk.id and su.state = 'ACTIVE'

--left join goodlife.privilege_usages pu on pu.target_service = 'Participation' and pu.target_center = main_part.center and pu.target_id = main_part.id 
--left join goodlife.clipcards cli on cli.center = pu.source_center and cli.id = pu.source_id and cli.subid = pu.source_subid
--left join goodlife.products clip_pdt on clip_pdt.center = cli.center and clip_pdt.id = cli.id

where 
bk.main_booking_center is null --and bk.recurrence_at_planned = 1 
--and bk.recurrence_end is not null 
and bk.class_capacity <= 2 --and dependant_bk.center is null
and part.center is null and bk.state = 'ACTIVE' and (
ac.activity_type = 4 or 
(ac.activity_type = 2 and ac.activity_group_id = 7
)
)
and bk.owner_center is not null

SELECT	bk.center as "ClubNumber",	
		bk.center || 'bk' || bk.Id as "ExerpBookingId",
		TO_CHAR(longtodateC(bk.starttime, bk.center), 'YYYY-MM-DD HH24:MI:SS') as "StartDateTime",
		TO_CHAR(longtodateC(bk.stoptime, bk.center), 'YYYY-MM-DD HH24:MI:SS') as "StopDateTime",	
		bk.name as "ActivityName",
		staff.external_id as "StaffExerpId",
		staff.fullname as "StaffFullName",
		member.external_id as "MemberExerpId",
		member.fullname as "MemberFullName",
		bk.main_booking_center || 'bk' || bk.main_booking_id as "ExerpMainBookingId"	
FROM    goodlife.bookings bk
			LEFT JOIN goodlife.participations pa ON bk.center = pa.booking_center AND bk.id = pa.booking_id
			JOIN goodlife.activity ac ON bk.activity = ac.id
			JOIN goodlife.staff_usage su ON bk.center=su.booking_center AND bk.id=su.booking_id
			JOIN goodlife.persons staff ON staff.center=su.person_center AND staff.id=su.person_id
			LEFT JOIN goodlife.persons member ON member.center=bk.owner_center AND member.id=bk.owner_id
WHERE	pa.Id IS NULL
		AND ac.activity_group_id=6
		AND bk.state = 'ACTIVE'
		AND bk.starttime >= CAST((to_date('7-3-2017', 'MM-DD-YYYY')-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000
		AND bk.starttime <= CAST((to_date('8-2-2017', 'MM-DD-YYYY')-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000
		AND ac.Id NOT IN (164, 1203)
		AND su.state = 'ACTIVE'
ORDER BY bk.Center, bk.starttime
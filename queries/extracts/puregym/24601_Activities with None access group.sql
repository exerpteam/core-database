-- The extract is extracted from Exerp on 2026-02-08
-- Activities with None access group, main goal is to ensure all of them ahve a acticity group set and then the max open bookings work as expected
SELECT a.SCOPE_ID Gym_ID, a.name Activity, a.DURATION_LIST Class_Duration, a.DESCRIPTION Description
FROM PUREGYM.ACTIVITY a
join PUREGYM.PARTICIPATION_CONFIGURATIONS pa on a.ID=pa.ACTIVITY_ID and pa.NAME='Class'
where pa.ACCESS_GROUP_ID is null and a.STATE='ACTIVE'
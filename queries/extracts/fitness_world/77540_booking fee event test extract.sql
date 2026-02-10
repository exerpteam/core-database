-- The extract is extracted from Exerp on 2026-02-08
--  
Select
par.PARTICIPANT_CENTER ||'p'|| par.PARTICIPANT_id as PERSONKEY,
b.name,
longtodate(b.STARTTIME),
pg.PUNISHMENT,
par.NO_SHOW_UP_PUNISH_STATE,
pg.USAGE_PRODUCT,
longtodate(pu.plan_TIME),
par.center,
par.id,
pu.GRANT_ID


From Bookings b

join participations par 
on 
par.booking_center = b.center
and
par.booking_id = b.id
and par.state != 'CANCELLED'

join privilege_usages pu
    on
        par.CENTER = pu.TARGET_CENTER
    AND par.ID = pu.TARGET_ID
   	AND pu.TARGET_SERVICE = 'Participation'
 	and pu.state = 'PLANNED'
JOIN PRIVILEGE_GRANTS pg
    ON
        pg.ID = pu.GRANT_ID
and pg.USAGE_PRODUCT is not NULL
where
b.center in (:scope)
 and par.SHOWUP_TIME is null
and longtodate(b.starttime) > sysdate
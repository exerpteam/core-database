-- The extract is extracted from Exerp on 2026-02-08
--  
select
b.CENTER CENTER,
c.NAME CENTERNAME,
b.NAME CLASS_NAME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME,
par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS EXERPID,
p.FULLNAME AS Medlemsnavn,
PR.name as subname
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
left join centers c
on b.center = c.ID
LEFT JOIN PERSONS p
ON p.CENTER = par.PARTICIPANT_CENTER
AND p.ID = par.PARTICIPANT_ID
LEFT JOIN SUBSCRIPTIONS s
ON s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
JOIN PRODUCTS pr
ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID = s.SUBSCRIPTIONTYPE_ID
where
b.STATE = 'ACTIVE'
AND s.STATE in (2,4)
AND s.OWNER_ID = p.ID
AND par.state != 'CANCELLED'
AND b.NAME IN ('Yoga','Mobility 25')
AND b.starttime >= :FROMDATE
AND b.starttime <= :TODATE
AND b.CENTER in (:scope)
AND pr.name IN ('Core','Fitness Basic')
ORDER BY
b.CENTER,
STARTTIME,
(par.CENTER ||'book'|| par.ID)

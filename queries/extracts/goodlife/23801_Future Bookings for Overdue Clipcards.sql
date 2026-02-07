SELECT

p.center||'p'||p.id AS "Person ID"
,p.fullname AS "Person Name"
,b.center AS "Booking Center"
,TO_CHAR(LONGTODATEC(b.starttime,b.center),'YYYY-MM-DD') AS "Booking Date"
,b.name as "Booking Name"
,staff.fullname AS "Staff Name"

FROM

clipcards c

JOIN privilege_usages pu
ON pu.source_center = c.center
AND pu.source_id = c.id
AND pu.source_subid = c.subid
AND c.overdue_since > 
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END

JOIN participations pa
ON pu.target_center = pa.center
AND pu.target_id = pa.id
AND pu.target_service = 'Participation'

JOIN bookings b
ON pa.booking_center = b.center
AND pa.booking_id = b.id
AND b.state != 'CANCELLED'
AND b.starttime > CAST (extract(epoch FROM now() ) AS bigint)*1000 -1000

JOIN persons p
ON c.owner_center = p.center
AND c.owner_id = p.id

JOIN staff_usage su
ON su.booking_center = b.center
AND su.booking_id = b.id
AND su.state != 'CANCELLED'

JOIN persons staff
ON su.person_center = staff.center
AND su.person_id = staff.id

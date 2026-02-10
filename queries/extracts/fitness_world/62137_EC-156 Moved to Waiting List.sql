-- The extract is extracted from Exerp on 2026-02-08
-- EC-156
SELECT 
    p.participant_center || 'p' || p.participant_id AS WAITING_LIST_MEMBERS, 
    b.NAME, 
    longtodatec(b.STARTTIME, b.center), 
    p.PARTICIPATION_NUMBER
FROM 
    BOOKINGS b
    JOIN participations p ON b.center = p.BOOKING_CENTER AND b.id = p.BOOKING_ID
WHERE 
    p.PARTICIPATION_NUMBER > 9 
    AND b.NAME LIKE (:Aktivitet) 
    AND p.LAST_MODIFIED > 1603706940000
	AND b.starttime > :from_date --default 01042023
ORDER BY 
    b.center

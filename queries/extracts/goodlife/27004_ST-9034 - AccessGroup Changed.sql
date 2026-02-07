WITH PARAMS AS
(
        SELECT
                datetolongC(to_char(to_date(getcentertime(c.id),'YYYY-MM-DD HH24:MI:SS')+8,'YYYY-MM-DD HH24:MI:SS'),c.ID) AS today,
                c.ID AS centerId
        FROM
                centers c
)
SELECT
        a.ID,
        a.NAME,
        longtodateC(b.starttime, b.CENTER) AS StartTime,
        longtodateC(b.stoptime, b.CENTER) AS StopTime,
        b.state,
		b.center,
        p.participant_center || 'p' || p.participant_id,
        p.state AS ParticipationState
FROM goodlife.activity a
JOIN goodlife.bookings b ON a.id = b.activity
JOIN PARAMS ON params.centerId = b.center
JOIN goodlife.participations p ON p.booking_center = b.center AND p.booking_id = b.id
WHERE
        b.activity IN (6801,8801)       
        AND b.starttime > params.today
        AND b.state != 'CANCELLED'
        AND p.state != 'CANCELLED'
ORDER BY 
        b.starttime

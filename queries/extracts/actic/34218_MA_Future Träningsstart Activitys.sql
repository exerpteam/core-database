WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DISTINCT datetolongTZ(to_char(exerpsysdate(),'YYYY-MM-DD HH24:MI'), c.TIME_ZONE) AS currentDate
        FROM
            CENTERS c
        WHERE
          c.TIME_ZONE IS NOT NULL
    )
        
SELECT
    p.EXTERNAL_ID AS PersonExternalId,
	cen.name,
    p.CENTER || 'p' || p.ID AS PersonId,
    b.CENTER || 'book' || b.ID AS BookingId,
    to_char(longtodateC(b.CREATION_TIME, b.CENTER),'YYYY-MM-DD') AS "CREATION DATE",
	part.CENTER,
   	cen.name,
    to_char(longtodateC(b.STARTTIME, b.CENTER),'YYYY-MM-DD') AS "Date",
    to_char(longtodateC(b.STARTTIME, b.CENTER),'HH24:MI') AS StartTime,
    to_char(longtodateC(b.STOPTIME, b.CENTER),'HH24:MI') AS StopTime,
    su.PERSON_CENTER || 'p' || su.PERSON_ID AS InstructorKey,
    part.STATE AS ParticipationState,
    a.ACTIVITY_GROUP_ID AS ActivityGroupId,
    ag.NAME AS ActivityGroupName,
    a.ID AS ActivityId,
    a.NAME AS ActivityName
FROM
    PERSONS p
CROSS JOIN params
JOIN
    PARTICIPATIONS part ON p.CENTER = part.PARTICIPANT_CENTER AND p.ID = part.PARTICIPANT_ID

JOIN centers cen
ON
cen.id = part.booking_center

JOIN    
    BOOKINGS b ON b.CENTER = part.BOOKING_CENTER AND b.ID = part.BOOKING_ID
JOIN
    ACTIVITY a ON b.ACTIVITY = a.ID
JOIN
    ACTIVITY_GROUP ag ON a.ACTIVITY_GROUP_ID = ag.ID
JOIN 
    STAFF_USAGE su ON su.BOOKING_CENTER = b.CENTER AND su.BOOKING_ID = b.ID
WHERE
    --a.ACTIVITY_TYPE = 4
     a.ID IN (34065, 34068, 31608, 31610, 36007, 18822, 18823)
    AND a.state = 'ACTIVE'
    AND b.STATE != 'CANCELLED'
    AND part.START_TIME > params.currentDate
    AND b.CENTER IN (:Scope)
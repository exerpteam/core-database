SELECT
    p.CENTER||'p'||p.ID,
    longtodate(pa.SHOWUP_TIME) as showup,
    ac.NAME,
    ac.ACTIVITY_GROUP_ID
    
    
FROM
    PUREGYM.PERSONS p
JOIN
    PUREGYM.PARTICIPATIONS pa
ON
    pa.PARTICIPANT_CENTER = p.CENTER
    AND pa.PARTICIPANT_ID = p.ID
    and pa.USER_INTERFACE_TYPE = 1
    and pa.STATE = 'PARTICIPATION'
    and longtodate(pa.SHOWUP_TIME) between sysdate - 3 and sysdate
JOIN
    PUREGYM.BOOKINGS bo
ON
    pa.BOOKING_CENTER = bo.CENTER
    AND pa.BOOKING_ID = bo.ID
JOIN PUREGYM.ACTIVITY ac on ac.ID = bo.ACTIVITY and ac.ACTIVITY_GROUP_ID = :ActivityGroup

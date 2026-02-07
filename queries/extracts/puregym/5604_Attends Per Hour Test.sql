SELECT
    COUNT(DISTINCT CIL.PERSON_CENTER || 'p' || CIL.PERSON_ID) AS C
FROM
    CHECKINS CIL
WHERE
    
        CIL.CHECKIN_CENTER IN(:scope)
        AND CIL.CHECKIN_TIME >= datetolongTZ(to_char(:start_time, 'YYYY-MM-DD HH24:MI'), 'Europe/London')
        AND CIL.CHECKIN_TIME <=datetolongTZ(to_char(:end_time, 'YYYY-MM-DD HH24:MI'), 'Europe/London')-1

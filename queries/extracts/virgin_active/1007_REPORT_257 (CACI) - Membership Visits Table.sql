SELECT
    p.UNIQUE_KEY "Members ID",
    p.CENTER || 'p' || p.ID "SysMemberID",
    c.NAME "Club",
    TO_CHAR(longToDateC(cin.CHECKIN_TIME,p.center),'YYYYmmDD HH24:MI:SS') "DateTime"
FROM
    PERSONS_VW p
JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
JOIN CENTERS c
ON
    c.ID = cin.CHECKIN_CENTER
/*
WHERE
    cin.CHECKIN_TIME BETWEEN dateToLongC(TO_CHAR(TRUNC(sysdate-1), 'YYYY-MM-dd HH24:MI'),p.center) AND (dateToLongC(TO_CHAR(TRUNC(sysdate), 'YYYY-MM-dd HH24:MI')),p.center)-1
*/
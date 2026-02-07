SELECT
    p.UNIQUE_KEY "Members ID",
    p.CENTER || 'p' || p.ID "SysMemberID",
    c.NAME "Club",
    TO_CHAR(longToDate(cin.CHECKIN_TIME),'YYYYmmDD HH24:MI:SS') "DateTime"
FROM
    PERSONS_VW p
JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
JOIN CENTERS c
ON
    c.ID = cin.CHECKIN_CENTER
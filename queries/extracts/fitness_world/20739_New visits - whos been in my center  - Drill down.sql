-- This is the version from 2026-02-05
--  
SELECT
    c.CHECKIN_CENTER,
    tc.shortname center_name,
    c.PERSON_CENTER from_center,
    hc.shortname from_center_name,
    COUNT(c.PERSON_CENTER),
    p.CENTER,
    p.ID,
    p.STATUS,
    p.FIRSTNAME,
    p.MIDDLENAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.COUNTRY,
    p.ZIPCODE,
    p.CITY,
    p.BIRTHDATE,
    p.SEX
FROM
    FW.CHECKINS c
JOIN FW.CENTERS hc
ON
    hc.ID = c.PERSON_CENTER
JOIN FW.CENTERS tc
ON
    tc.ID = c.CHECKIN_CENTER
JOIN FW.PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
    AND p.ID = c.PERSON_ID
WHERE
    c.CHECKIN_CENTER = :center
    AND c.CHECKIN_TIME BETWEEN :fromDate AND :toDate
GROUP BY
    c.PERSON_CENTER,
    c.CHECKIN_CENTER,
    hc.SHORTNAME,
    tc.SHORTNAME,
    p.CENTER,
    p.ID,
    p.STATUS,
    p.FIRSTNAME,
    p.MIDDLENAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.COUNTRY,
    p.ZIPCODE,
    p.CITY,
    p.BIRTHDATE,
    p.SEX
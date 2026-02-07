-- This is the version from 2026-02-05
--  
SELECT
    c.PERSON_CENTER home_Center,
    hc.SHORTNAME home_Center_Name,
    c.CHECKIN_CENTER to_center,
    tc.SHORTNAME to_center_name,
    COUNT(p.CENTER) cnt,
    p.CENTER || 'p' || p.ID pid,
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
    c.PERSON_CENTER = :center
    AND c.CHECKIN_TIME BETWEEN :fromDate AND :toDate
GROUP BY
    c.PERSON_CENTER ,
    hc.SHORTNAME ,
    c.CHECKIN_CENTER ,
    tc.SHORTNAME,   
    p.CENTER,p.ID,
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
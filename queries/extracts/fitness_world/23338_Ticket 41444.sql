-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    c.CHECKIN_CENTER Club,
    p.CENTER || 'p' || p.ID Member_id,
    p.SEX Sex,
    floor(months_between(TRUNC(exerpsysdate()),p.BIRTHDATE)/12) Age,
    p.ADDRESS1 Address,
    p.ZIPCODE Postal_number,
    p.CITY City
FROM
    FW.CHECKINS c
JOIN FW.PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
    AND p.id = c.PERSON_ID
WHERE
    c.CHECKIN_TIME BETWEEN :checkinFrom AND :checkinTo
    AND c.CHECKIN_CENTER IN (:scope)
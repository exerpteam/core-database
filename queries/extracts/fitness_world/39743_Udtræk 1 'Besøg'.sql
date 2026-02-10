-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2722
WITH
    PARAMS AS
    (
        SELECT /*+ materialize */
               $$fromDate$$ AS fromDate,
               $$toDate$$ + 24 * 3600 * 1000 AS toDate
        FROM DUAL
    )
SELECT DISTINCT
        per.CENTER || 'p' || per.ID AS "Medlemsnummer", 
        DECODE (per.SEX, 'C', 'Company','M','MALE','F','FEMALE') AS "Køn",
        floor(months_between(exerpsysdate(), per.BIRTHDATE) / 12) AS "Alder",
        per.ZIPCODE AS "Post nr.(medlem)", 
        to_char(exerpro.longtodate(ch.CHECKIN_TIME), 'YYYY-MM-dd HH24:MI') AS "Checkin Tidspunkt",
        ch.CHECKIN_CENTER AS "Center nr.",
        cen.ZIPCODE AS "Post nr.(center)"
FROM 
        PARAMS,
        PERSONS per
JOIN    CHECKINS ch  
    ON  per.CENTER = ch.PERSON_CENTER 
        AND per.ID = ch.PERSON_ID
JOIN    CENTERS cen
    ON cen.ID = ch.CHECKIN_CENTER
WHERE
        ch.CHECKIN_TIME >= PARAMS.fromDate
    AND ch.CHECKIN_TIME <= PARAMS.toDate
    AND ch.CHECKIN_CENTER IN (:scope)
GROUP BY
	per.CENTER, 
        per.ID,
        per.SEX,
        per.BIRTHDATE,
        ch.CHECKIN_CENTER,
        ch.CHECKIN_TIME,
        per.ZIPCODE,
        cen.ZIPCODE


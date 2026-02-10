-- The extract is extracted from Exerp on 2026-02-08
-- From Batch Exports Marketo extract Checkins
WITH PARAMS AS
(
        SELECT
                /*+ materialize */
                datetolong(TO_CHAR(CURRENT_DATE -5, 'YYYY-MM-DD HH24:MM')) AS FROMDATE,
                datetolong(TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD HH24:MM')) AS TODATE
)
SELECT distinct
c.shortname AS Member_Club,
    p2.EXTERNAL_ID,
p2.center||'p'||p2.id AS MemberID,
    ch.CHECKIN_CENTER,
CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
    TO_CHAR(longtodate(ch.CHECKIN_TIME),'yyyy-MM-dd HH24:MI') AS CHECKIN_TIME,
to_char(longToDate(ch.CHECKout_TIME),'yyyy-MM-dd HH24:MI:SS')                           AS checkOut
/*ch.CHECKout_TIME - ch.CHECKIN_TIME as TrainingTime */

FROM
    CHECKINS ch
CROSS JOIN PARAMS
JOIN
    PERSONS p
ON
    p.CENTER = ch.PERSON_CENTER
    AND p.id = ch.PERSON_ID
JOIN
    PERSONS p2
ON
    p2.center = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
JOIN
   CENTERS c
ON
    c.id = p2.center      
WHERE
    p2.STATUS NOT IN (4,5,7,8)
    AND p2.PERSONTYPE != 2
	AND c.COUNTRY IN ('DE')
    AND ch.CHECKIN_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND p2.center IN (:center)
	
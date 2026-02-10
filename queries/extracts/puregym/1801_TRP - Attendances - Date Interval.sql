-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    NULL                                                AS remote_chain_id,
    ci.PERSON_CENTER                                    AS remote_site_id,
    p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                          AS remote_user_id,
    TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'),'YYYY-MM-dd HH24:MI') AS in_timestamp,
    NULL                                                                         AS source_id,
    ci.CHECKIN_CENTER                                                            AS location_site_id,
    DECODE(pea.TXTVALUE,'true',1,0)                                              AS SMSMARKETING
FROM
    CHECKINS ci
JOIN
    persons p
ON
    p.CENTER = ci.PERSON_CENTER
    AND p.id = ci.PERSON_ID
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    p.CENTER = pea.PERSONCENTER
    AND p.ID = pea.PERSONID
    AND pea.NAME = 'SMSMARKETING'
WHERE
    ci.CHECKIN_TIME >= :FromDate
AND ci.CHECKIN_TIME < (:ToDate + 24*3600*1000)
AND ci.PERSON_CENTER IN (:scope)
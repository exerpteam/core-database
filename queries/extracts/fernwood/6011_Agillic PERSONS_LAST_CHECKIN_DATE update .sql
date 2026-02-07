SELECT
    p.EXTERNAL_ID AS "PERSON_ID",
    TO_CHAR(longtodatetz(che.CHECKIN_TIME, cen.time_zone),'yyyy-MM-dd') AS "LAST_CHECKIN_DATE"
FROM
    persons p
JOIN
    checkins che
ON
    che.id =
    (
        SELECT
            id
        FROM
            checkins c
        WHERE
            c.person_center = p.center
        AND c.person_id = p.id
        AND c.checkin_result = 1
        ORDER BY
            checkin_time DESC LIMIT 1 ) 
JOIN
    centers cen
ON
    cen.id = che.CHECKIN_CENTER            
WHERE
    -- Exclude Transferred
p.external_id IS NOT NULL
    -- Exclude companies
AND p.SEX != 'C'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
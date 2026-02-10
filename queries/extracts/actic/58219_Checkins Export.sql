-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
    ,
    center_map AS materialized
    (
        SELECT
            c.id AS OldCenterID,
            c.id AS NewCenterID
        FROM
            centers c
        WHERE
            c.id IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,700,
                     730,
                     733,728,762,783,782,737,743,7084,725)
    )
SELECT
    (p.Center || 'p' || p.Id)                                                AS PersonId,
    COALESCE( checking_center_map.NewCenterID,person_center_map.NewCenterID) AS CenterId,
    TO_CHAR(longtodate(ch.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI:SS')            AS CheckinDate,
    --'1'                                                                      AS CheckinStatus
    CASE
        WHEN ch.CHECKIN_RESULT IN (0,1,2)
        THEN 'OK'
        WHEN ch.CHECKIN_RESULT = 3
        THEN 'Rejected'
    END AS CheckinStatus
FROM
    plist AS p
JOIN
    CHECKINS ch
ON
    ch.PERSON_CENTER = p.Center
AND ch.PERSON_ID = p.Id
LEFT JOIN
    center_map AS checking_center_map
ON
    checking_center_map.OldCenterID = ch.checkin_center
LEFT JOIN
    center_map AS person_center_map
ON
    person_center_map.OldCenterID = p.center
WHERE
    ch.CHECKIN_RESULT != 3
AND ch.CHECKIN_TIME > 1386025200000
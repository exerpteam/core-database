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
SELECT
    p.center||'p'||p.id                           AS PersonId,
    TO_CHAR(longtodate(m.senttime), 'YYYY-MM-DD') AS TransactionDate,
    CASE m.deliverymethod
        WHEN 0
        THEN 'STAFF'
        WHEN 1
        THEN 'EMAIL'
        WHEN 2
        THEN 'SMS'
        WHEN 3
        THEN 'PERSINTF'
        WHEN 4
        THEN 'BLOCKPERSINTF'
        WHEN 5
        THEN 'LETTER'
        WHEN 6
        THEN 'MOBILE_API'
        WHEN 7
        THEN 'STAFF_APP_NOTIFICATION'
        WHEN 8
        THEN 'MEMBER_APP_NOTIFICATION'
        ELSE 'Undefined'
    END       AS Channel,
    m.subject AS Subject,
    m.payload AS Details,
    CASE
        WHEN m.deliverycode IN (0,3,7,9,10,11,14)
        THEN 'NO'
        ELSE 'Yes'
    END AS Delivered
FROM
    plist p
JOIN
    messages m
ON
    m.center = p.center
AND m.id = p.id
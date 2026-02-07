WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(current_date - interval '31 day', 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(current_date,
            'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
            c.country                            AS country,
            c.id                                 AS centerId
        FROM
            centers c
        WHERE
            c.id in (:Scope)
    ) 
SELECT
params.country  AS "Country",
    TO_CHAR(longtodateC(me.senttime, me.center), 'DD-MM-YYYY HH24:MI:SS')     AS "Creation Date",
    p.center ||'p'|| p.id                                                     AS "Member ID",
    p.external_id                                                             AS "External ID",
    TO_CHAR(longtodateC(me.receivedtime, me.center), 'DD-MM-YYYY HH24:MI:SS') AS "Delivery Time", TO_CHAR(longtodateC(me.receivedtime, me.center), 'DD.MM.YYYY')            AS "Delivery Date",
    CASE DELIVERYCODE
        WHEN 0
        THEN 'UNDELIVERED'
        WHEN 1
        THEN 'STAFF'
        WHEN 2
        THEN 'EMAIL'
        WHEN 3
        THEN 'EXPIRED'
        WHEN 4
        THEN 'KIOSK'
        WHEN 5
        THEN 'WEB'
        WHEN 6
        THEN 'SMS'
        WHEN 7
        THEN 'CANCELED'
        WHEN 8
        THEN 'LETTER'
        WHEN 9
        THEN 'FAILED'
        WHEN 10
        THEN 'UNCHARGABLE'
        WHEN 11
        THEN 'UNDELIVERABLE'
        WHEN 12
        THEN 'MOBILE_API'
        WHEN 13
        THEN 'APP_NOTIFICATION'
        WHEN 14
        THEN 'SCHEDULED'
        ELSE 'Undefined'
    END        AS "Delivery Method",
    me.subject AS "Subject",
    CASE me.DELIVERYMETHOD
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
    END AS "Channel"
FROM
    messages me
JOIN
    params
ON
    params.centerID = me.center
JOIN
    persons p
ON
    p.center = me.center
AND p.id = me.id
WHERE
    me.deliverymethod IN (1,2)
AND REFERENCE LIKE '%ccol%'
AND me.senttime BETWEEN params.fromDate AND params.toDate
ORDER BY
me.senttime
WITH params AS MATERIALIZED
(
        SELECT
                :checkinStartDate                  AS FromDate,
                (:checkinEndDate + 86400 * 1000) - 1 AS ToDate
)
SELECT
        p.center || 'p' || p.id                                        AS PERSONID,
        c.id                                                           AS CheckinCenterId,
        c.name                                                         AS CheckinCenter,
        TO_CHAR(longToDateC(cil.checkin_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
        TO_CHAR(longToDateC(cil.checkout_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime
FROM sats.persons p
CROSS JOIN params
JOIN sats.checkins cil
        ON cil.person_center = p.center
        AND cil.person_id = p.id
        AND cil.checkin_time BETWEEN params.FromDate AND params.ToDate
JOIN centers c
        ON c.id = cil.checkin_center
WHERE
        p.status NOT IN (4,5,7,8)
        AND p.center IN(:scope)

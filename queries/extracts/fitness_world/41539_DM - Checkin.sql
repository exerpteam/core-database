-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$checkinStartDate$$                      AS FromDate,
            ($$checkinEndDate$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
SELECT
    p.center || 'p' || p.id                                        AS PERSONID,
    c.id                                                           AS CheckinCenterId,
    c.name                                                         AS CheckinCenter,
    TO_CHAR(longToDate(cil.checkin_time),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
    TO_CHAR(longToDate(cil.checkout_time),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime
FROM
    PERSONS p
CROSS JOIN
    params
JOIN
    CHECKINS cil
ON
    cil.PERSON_CENTER = p.center
    AND cil.PERSON_ID = p.id
    AND cil.CHECKIN_TIME BETWEEN params.FromDate AND params.ToDate
JOIN
    centers c
ON
    c.id = cil.checkin_center
WHERE
    p.CENTER IN($$scope$$)
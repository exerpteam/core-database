WITH
    params AS Materialized
    (
        SELECT
            ID as center,
            CAST(datetolongC(TO_CHAR(CAST($$checkinStartDate$$ AS DATE),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT)  AS FromDate,
            CAST(datetolongC(TO_CHAR(CAST($$checkinEndDate$$ AS DATE),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) + 86400*1000 - 1  AS ToDate
        FROM 
            centers    
    )
SELECT
    p.center || 'p' || p.id                                        AS PERSONID,
    c.id                                                           AS CheckinCenterId,
    c.name                                                         AS CheckinCenter,
    TO_CHAR(longToDateC(cil.checkin_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
    TO_CHAR(longToDateC(cil.checkout_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime
FROM
    PERSONS p
JOIN
    params
ON
    params.center = p.center    
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
    p.CENTER IN ($$scope$$)
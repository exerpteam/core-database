WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$checkinStartDate$$                      AS FromDate,
            ($$checkinEndDate$$ + 86400 * 1000) - 1 AS ToDate
        
    )
SELECT
    p.center || 'p' || p.id                                        AS PERSONID,
	email.txtvalue 												   AS EMAIL,
    c.id                                                           AS CheckinCenterId,
    c.name                                                         AS CheckinCenter,
    TO_CHAR(longToDateC(cil.checkin_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
    TO_CHAR(longToDateC(cil.checkout_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime

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
FULL JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
WHERE
    p.CENTER IN($$scope$$)

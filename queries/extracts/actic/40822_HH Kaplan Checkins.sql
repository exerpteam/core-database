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
    p.center || 'p' || p.id                                       AS PERSONID,
    c.id                                                           AS CheckinCenterId,
    c.name                                                         AS CheckinCenter,
    TO_CHAR(longToDateC(cil.checkin_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
    TO_CHAR(longToDateC(cil.checkout_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime,
	prod.NAME
FROM
    PERSONS p
CROSS JOIN
    params
JOIN
    CHECKINS cil
ON
    cil.PERSON_CENTER = p.CENTER
    AND cil.PERSON_ID = p.ID
    AND cil.CHECKIN_TIME BETWEEN params.FromDate AND params.ToDate
JOIN
    CENTERS c
ON
    c.id = cil.CHECKIN_CENTER 
RIGHT JOIN SUBSCRIPTIONS sub ON 
	sub.OWNER_CENTER = p.CENTER
	AND sub.OWNER_ID = p.ID
	AND sub.STATE IN (2, 4, 8)
	   		
	JOIN SUBSCRIPTIONTYPES st 
    	ON sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER 
    	AND sub.SUBSCRIPTIONTYPE_ID = st.ID 
	JOIN PRODUCTS prod 
    	ON 
    	st.CENTER = prod.CENTER 
    	AND st.ID = prod.ID
		AND prod.NAME != 'Actic Anywhere'
WHERE
    p.CENTER IN($$scope$$)
ORDER BY
	p.CENTER,
	p.ID
	
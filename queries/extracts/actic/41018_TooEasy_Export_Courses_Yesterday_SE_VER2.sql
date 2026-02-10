-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')  AS STOPTIME,

	CASE 
		WHEN LOWER(act.NAME) LIKE '%small group%' THEN 'Actic small group training'	
		WHEN LOWER(act.NAME) LIKE '%pt bootcamp%' THEN 'PT Bootcamp'
		WHEN LOWER(act.NAME) LIKE '%fit%' THEN 'FIT'
		WHEN LOWER(act.NAME) LIKE '%kom i%' THEN 'Kom i form'
	ELSE 'Simskola'
	END AS activityname,
    c.EXTERNAL_ID                                 AS Cost,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
	ins.ssn
FROM
    BOOKINGS bk
JOIN PARAMS params ON params.CenterID = bk.CENTER
JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN
    STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
AND bk.id = st.BOOKING_ID
LEFT JOIN
    PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
AND st.PERSON_ID = ins.ID
LEFT JOIN
    Centers c
ON
    BK.center = c.id

-- Below join to remove courses without participants
JOIN 
	(
		SELECT 
			par.BOOKING_CENTER par_center,
			par.BOOKING_id par_id,
			COUNT(*) AS CNT 
		FROM PARTICIPATIONS par
		GROUP BY
			par.BOOKING_CENTER,
			par.BOOKING_ID	
	) cn
ON 
	bk.CENTER = cn.par_center
	AND bk.ID = cn.par_id
WHERE
    act.ACTIVITY_TYPE = '9'
AND bk.STARTTIME >= params.fromDate 
	-- yesterday at midnight
AND bk.STARTTIME < params.toDate 
AND bk.CENTER != 102 -- Exclude Sydpoolen
    -- yesterday at midnight +24 hours --in ms	
AND bk.STATE = 'ACTIVE'
AND c.COUNTRY = 'SE'
AND st.STATE != 'CANCELLED'
AND cn.CNT > 0

ORDER BY
    bk.STARTTIME

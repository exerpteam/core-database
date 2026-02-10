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
	    CAST ( bk.center AS VARCHAR(255)) AS "SCOPE 4",
		CAST ( c.External_ID AS VARCHAR(255)) AS "COST",
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') AS "DATE",
	TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI') StartTime,  
	TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI') StopTime,
	TO_CHAR(longtodate(bk.STARTTIME), 'DAY') WeekDay,    
	act.name,
	ins.Fullname AS Instructor,
	bk.CLASS_CAPACITY AS CAPACITY,
	COALESCE(per_booked_bk.par_count,0) BOOKED,
	COALESCE(per_booked_bk.par_count,0) / nullif (bk.CLASS_CAPACITY,0) AS BookingPercentage,
	COALESCE(per_pat_bk.par_count1,0) Showups,
	COALESCE(per_pat_bk.par_count1,0) / nullif(per_booked_bk.par_count,0) ShowupPercentage,
COALESCE(per_pat_bk.par_count1,0) / nullif(bk.CLASS_CAPACITY, 0) LoadFactor,
	COALESCE(per_booked_bk.par_count,0) - COALESCE(per_pat_bk.par_count1,0) AS Absentees

		
	FROM
    BOOKINGS bk

	
	
JOIN PARAMS params ON params.CenterID = bk.CENTER

	
LEFT JOIN
    (
        
		SELECT
            COUNT(*) par_count,
            bk.center,
            bk.id
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('BOOKED', 'PARTICIPATION')
			AND SHOWUP_TIME IS NOT NULL
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            bk.center,
			bk.id
	
    )
    per_booked_bk
ON
    per_booked_bk.center = bk.center
AND per_booked_bk.id = bk.id



LEFT JOIN
    (
        
		SELECT
            COUNT(*) par_count1,
            bk.center,
            bk.id
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('PARTICIPATION')
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            bk.center,
			bk.id
	
    )
    per_pat_bk
ON
    per_pat_bk.center = bk.center
AND per_pat_bk.id = bk.id






JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID

	
JOIN
    STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
AND bk.id = st.BOOKING_ID


JOIN
    PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
AND st.PERSON_ID = ins.ID


LEFT JOIN
    Centers c
ON
    BK.center = c.id

	
	


WHERE
    bk.center IN (:Scope)
AND act.ACTIVITY_TYPE = '2'
AND act.id NOT IN (36618,36224,36449)
    --AND bk.STARTTIME >= FromDate
    --AND bk.STARTTIME < ToDate + 3600*1000*24
AND bk.STARTTIME >= params.fromDate -- yesterday at
    -- midnight
AND bk.STARTTIME < params.toDate --
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'

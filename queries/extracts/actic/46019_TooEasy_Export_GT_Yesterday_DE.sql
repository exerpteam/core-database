-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Export yesterdays GT-sessions without exceptions.
*/
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
    act.NAME                                         activityname,
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
WHERE
    bk.center IN (:scope)
	AND act.ACTIVITY_TYPE = '2'
	AND act.ID NOT IN (46807, 53407)
	AND (
		ins.FIRSTNAME NOT LIKE('Actic%')
		AND ins.FIRSTNAME NOT LIKE('ACTIC%')
		AND ins.FIRSTNAME NOT LIKE('Schwimmbad%')
		AND ins.FIRSTNAME NOT LIKE('Schwimmen%')
		AND ins.FIRSTNAME NOT LIKE('Exerp%')
		AND (
			ins.FIRSTNAME NOT LIKE('Trainer%')
			AND ins.LASTNAME NOT LIKE('Sauna%')
		)
	)


--AND bk.STARTTIME >= : fromDate -- yesterday at
--AND bk.STARTTIME < : toDate -- yesterday at


AND bk.STARTTIME >= params.fromDate -- yesterday at
    -- midnight
AND bk.STARTTIME < params.toDate
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME

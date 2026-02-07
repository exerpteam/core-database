SELECT
    b.CENTER||'bk'||b.ID AS "MAIN_BOOKING_ID",
    CASE WHEN b.RECURRENCE_TYPE is null
        THEN 'NONE'
	WHEN b.RECURRENCE_TYPE = 1	
        THEN 'DAILY'
    WHEN b.RECURRENCE_TYPE = 2
        THEN 'WEEKLY'
    WHEN b.RECURRENCE_TYPE = 3
        THEN 'MONTHLY'
    END                                                                  AS "RECURRENCE_TYPE",
    b.RECURRENCE_DATA                                                    AS "RECURRENCE",
    TO_CHAR(longtodateC(b.STARTTIME, b.CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "RECURRENCE_START_DATETIME",
    b.RECURRENCE_END                                                     AS "RECURRENCE_END",
    b.CENTER                                                             AS "CENTER_ID"
FROM
    BOOKINGS b
WHERE
    b.MAIN_BOOKING_ID IS NULL
    AND b.CENTER = 76
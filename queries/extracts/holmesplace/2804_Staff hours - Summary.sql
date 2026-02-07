SELECT 
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') b_date,
    TO_CHAR(longtodate(bk.STOPTIME), 'MON') b_month,
    TO_CHAR(longtodate(bk.STOPTIME), 'DY') b_day,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI') startTime,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI') endTime,
    extract(HOUR FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME))) hours,
    extract(MINUTE FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME))) minutes,
    ROUND( (extract(MINUTE FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME))) / 60) + extract(HOUR FROM
    (longtodate (bk.STOPTIME)- longtodate(bk.STARTTIME))),2) timeTotal,
    psg.SALARY staffSalary,
    CASE
        WHEN psg.SALARY IS NOT NULL
            AND psg.SALARY <> 0
            AND psg.SCOPE_TYPE = 'C'
            AND psg.SCOPE_ID = bk.CENTER
        THEN ROUND( (extract(MINUTE FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME))) / 60) + extract(HOUR FROM
            (longtodate (bk.STOPTIME)- longtodate(bk.STARTTIME))),2) * psg.SALARY
        ELSE NULL
    END wages,
    act.NAME activityname,
    actgr.NAME activitygroup,
    stfg.NAME staffgroup,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
    bk.STATE bookingState
FROM
    BOOKINGS bk
JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID
JOIN
    ACTIVITY_GROUP actgr
ON
    act.ACTIVITY_GROUP_ID = actgr.ID
JOIN
    HP.ACTIVITY_STAFF_CONFIGURATIONS staffconfig
ON
    staffconfig.ACTIVITY_ID = act.ID
JOIN
    HP.STAFF_GROUPS stfg
ON
    stfg.ID = staffconfig.STAFF_GROUP_ID

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
    PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER = ins.CENTER
    AND psg.PERSON_ID = ins.ID
    AND psg.STAFF_GROUP_ID = stfg.ID
WHERE
--        bk.center IN (14)
--        AND longtodate(bk.STARTTIME) >= TO_DATE('2013-05-01', 'YYYY-MM-DD')
--        AND longtodate(bk.STARTTIME) < TO_DATE('2013-05-31', 'YYYY-MM-DD') + 1
    bk.center IN (:Center)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + (1000*60*60*24)
ORDER BY
    bk.STARTTIME

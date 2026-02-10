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
    --bk.id,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
    --c.name,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')  AS STOPTIME,
    act.NAME                                         activityname,
    c.EXTERNAL_ID                                 AS Cost,
    --bk.STATE bookingState,
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
    bk.center IN (9226)
AND (
        ins.center, ins.id) NOT IN ((143,13015),
                                    (143,1606),
                                    (143,28402),
                                    (131,20430),
                                    (131,42804),
                                    (143,3610),
                                    (134,51046),
                                    (9215,12408),
                                    (58,20421),
                                    (188,28646),
                                    (55,1111),
                                    (188,28646),
                                    (9215,12407),
                                    (188,29616),
                                    (188,28409),
                                    (9221,6077),
                                    (134,29052),
                                    (9234,1409),
                                    (99,51249),
                                    (9218,10602),
                                    (9226,8029),
                                    (9222,14605),
(157,54830),
(102,62650),
(58,49405),
(143,17424),
(134,59402),
(143,1867),
(108,37437),
(143, 59210),
(143, 76207),
(143, 76006),
(9236, 19829))

AND act.ACTIVITY_TYPE = '2'
AND act.id NOT IN (31607,
                   32410)
AND bk.STARTTIME >= 1630454400000 --September first 2021
    -- midnight
AND bk.STARTTIME < 1638316800000 -- First December 2021
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME
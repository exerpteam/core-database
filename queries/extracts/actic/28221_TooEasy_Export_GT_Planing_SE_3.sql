SELECT
	--bk.id,
	TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	--c.name,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
	c.EXTERNAL_ID as Cost,
    --bk.STATE bookingState,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
	ins.ssn
	--ins.center || 'p' || ins.id

    
FROM
    BOOKINGS bk
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID

LEFT JOIN STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
	



 
LEFT JOIN Centers c
on
BK.center = c.id 




WHERE
   

    bk.center IN (182, 184, 183, 186, 191, 193, 195, 194, 196, 192,	199, 55, 179, 9202,	9203, 9204, 9205, 9207,	9210, 9211, 9213, 175, 178, 185, 188, 197, 198, 200, 9206, 9208, 9209, 9212, 9214, 180, 1, 31, 80, 172, 99, 9215, 9217, 9218, 9216, 9219, 50, 140, 155, 18, 19, 29, 6, 8, 9, 16, 20,	23,	24,	76, 77,	108, 133, 151, 157, 163, 168, 171, 174, 36, 120, 68, 26,	53,	144, 84, 83, 139, 51, 167, 135, 12, 13, 164, 170, 189, 190, 40, 45, 130, 110, 33,	34,	35,	49,	81,	102, 129, 131, 134,	143, 150, 154, 14, 32, 54, 58, 136, 145, 173, 
52,	10,	128, 176, 177,	181, 9225,	9226, 9227,	9228, 9230,	9224, 9220, 9229, 56, 9222, 9232, 9221, 9223, 9232, 9234, 9233, 9235, 9236, 9237, 9238, 9239, 9256, 9257, 9262, 9263, 9264, 9265, 9171, 9258, 9267, 9269, 9270, 9271, 9272, 9273)
 


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
(9236, 19829),
(528, 84078))

    AND act.ACTIVITY_TYPE = '2'
		AND act.id NOT IN (31607, 32410, 4808, 34065, 37607, 88607, 93014)



   --AND bk.STARTTIME >= FromDate
    --AND bk.STARTTIME < ToDate + 3600*1000*24

	AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(current_date +32), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(current_date +47), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours --in ms



    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'



ORDER BY
    bk.STARTTIME

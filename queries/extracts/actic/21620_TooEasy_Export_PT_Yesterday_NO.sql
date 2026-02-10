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
SELECT DISTINCT
    --bk.id,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')    dato,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI')   AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')    AS STOPTIME,
    act.NAME                                           activityname,
    c.EXTERNAL_ID                                   AS COST,
    --par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END        instructorName,
    ins.ssn AS INSTRUCTOR_SSN
FROM
    BOOKINGS bk
JOIN PARAMS params ON params.CenterID = bk.CENTER
JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
AND par.BOOKING_ID = bk.ID
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
    PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
AND par.PARTICIPANT_ID = per.ID
LEFT JOIN
    Centers C
ON
    c.id = par.center
WHERE
    bk.center IN (543,
                  539,
                  541,
                  542,
                  535,
                  501,
                  502,
                  512,
                  513,
                  515,
                  516,
                  517,
                  518,
                  519,
                  523,
                  524,
                  525,
                  526,
                  527,
                  528,
                  529,
                  536,
                  537,
                  511,
                  522,
                  530,
                  531,
                  532,
                  533,
                  534,
                  538,
                  544,
                  545,
                  546,
				  547)
AND act.ID IN (22817,
               23407,
               22410,
               22417,
               22816,
               23408,
               22818,
               22815,
               23007,
               23409,
               31207,
               32214,
               34069,
               36413,
               36422,
               36414,
               36415,
               36417,
               36418,
               36419,
               36416,
               36420,
               36421,
               36454,
               36455,
               36456,
               36453,
               36457,
               36807,
               36452,
               36628,
			   43219,
			   43220,
			   43222,
			   43224,
			   52411,
				72408)
AND (
        ins.center, ins.id) NOT IN ((522,54865),
                                    (528,606),
                                    (528,9110),
                                    (528,1777),
                                    (528,5224),
                                    (538,1308),
                                    (533,17800),
                                    (522,704),
                                    (539,18602),
                                    (537,46201),
                                    (542,2202),
                                    (522,36264),
                                    (535,1),
                                    (535,2),
                                    (536,842),
                                    (536,843),
                                    (528,3471),
                                    (528,3472),
                                    (516,3261),
                                    (516,3262),
                                    (538,1202),
                                    (538,1203),
                                    (519,1401),
                                    (519,1400),
                                    (525,1264),
                                    (527,2570),
                                    (527,2571),
                                    (533,949),
                                    (533,950),
                                    (530,1462),
                                    (530,1463),
                                    (524,3207),
                                    (524,3208),
                                    (523,3555),
                                    (523,3556),
                                    (532,26023),
                                    (532,2799),
                                    (532,2800),
                                    (518,6401),
                                    (518,6402),
                                    (537,209),
                                    (537,210),
                                    (517,2017),
                                    (517,2018),
                                    (541,447),
                                    (512,3101),
                                    (512,3102),
                                    (502,1831),
                                    (502,1832),
                                    (541,29856),
                                    (522,53471),
                                    (530,36264),
                                    (527,47583),
                                    (537,11247),
                                    (545,1377),
                                    (545,2958),
                                    (544,413),
                                    (544,415),
                                    (545,1377),
                                    (544,10603),
                                    (544,422),
                                    (544,423),
                                    (544,606),
                                    (545,243),
                                    (544,419),
                                    (545,3004),
                                    (545,202),
                                    (544,424),(544,19209),(544,18060),(544,1027),(536,65814),(528,47081),(544,17473),(544,18061),(544,18062),(544,18060),(544,19209),(544,19210),(544,404),(544,34201),(527,81987),(544,16607),(528,70488),(528,52291),(542,38825),(544,54308),(522,103111),(528,104276),(542,39439),(522,113105),(545,60804),(544,74826),(544,75227),(544,401),(542,79825),(542,80023),(544,75227),(536,104218),(544,62205),(527,124990),(536,104218),(544,59042),(538,93207),(544,86586),(527,130584),(511,89839))
AND par.STATE LIKE 'PARTICIPATION'
    --AND bk.STARTTIME >= FromDate
    --AND bk.STARTTIME < ToDate + 3600*1000*24
AND bk.STARTTIME >= params.fromDate -- yesterday at
    -- midnight
AND bk.STARTTIME < params.toDate --
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'

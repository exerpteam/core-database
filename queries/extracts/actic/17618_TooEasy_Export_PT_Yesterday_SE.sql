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
    bk.center IN (182,
                  184,
                  183,
                  186,
                  191,
                  193,
                  195,
                  194,
                  196,
                  192,
                  199,
                  55,
                  179,
                  9202,
                  9203,
                  9204,
                  9205,
                  9207,
                  9210,
                  9211,
                  9213,
                  175,
                  178,
                  185,
                  188,
                  197,
                  198,
                  200,
                  9206,
                  9208,
                  9209,
                  9212,
                  9214,
                  180,
                  1,
                  31,
                  80,
                  172,
                  99,
                  9215,
                  9217,
                  9218,
                  9216,
                  9219,
                  50,
                  140,
                  155,
                  18,
                  19,
                  29,
                  6,
                  8,
                  9,
                  16,
                  20,
                  23,
                  24,
                  77,
                  108,
                  133,
                  151,
                  157,
                  163,
                  168,
                  171,
                  174,
                  36,
                  120,
                  68,
                  26,
                  53,
                  144,
                  84,
                  83,
                  139,
                  51,
                  167,
                  135,
                  12,
                  13,
                  164,
                  170,
                  189,
                  190,
                  40,
                  45,
                  130,
                  110,
                  33,
                  34,
                  35,
                  49,
                  81,
                  102,
                  129,
                  131,
                  134,
                  143,
                  150,
                  154,
                  14,
                  32,
                  54,
                  58,
                  136,
                  145,
                  173,
                  52,
                  10,
                  128,
                  176,
                  177,
                  181,
                  9225,
                  9226,
                  9227,
                  9228,
                  9230,
                  9224,
                  9220,
                  9229,
                  56,
                  9222,
                  9232,
                  9221,
                  9223,
                  9232,
                  9234,
                  9233,
                  9235,
				  9236,
				  9237,
				  9238, 
				  9239, 9257, 9262, 9263, 9171, 9258, 9267, 9269, 9270, 9271, 9272, 9273)

AND act.ID IN (4807, -- Personlig Träning (60 min)
               18818, -- INSTRUKTæR AG
               18821, -- StartPT (tidigare medlem)
               18822, -- Träningsstart 1 PT
               19407, -- Personlig Träning DUO
               18823, -- Träningsstart 1 PT
               24207, -- Personlig träning (30 min)
               34071, -- Träningsuppföljning PT
               34066, -- Treningsstart 2 PT
               34069, -- Träningsuppföljning PT
	           34068, -- Träningsstart 2 PT
			   64613, -- PT Get started 60 min
			   62212, -- Simskola Privat 30 min
			   59807, -- Simskola Privat barn 30 min
			   87207, -- PT Online 15 min	
			   86208, -- Simskola Privat 60 min
			   88230, -- Crawl Privat 30 min
			   88209 -- Crawl Privat 60 min

		)

	AND (
		(par.STATE LIKE 'PARTICIPATION')
		OR (par.STATE = 'CANCELLED' AND par.CANCELATION_REASON = 'NO_SHOW')
	)

    --AND bk.STARTTIME >= FromDate
    --AND bk.STARTTIME < ToDate + 3600*1000*24
AND bk.STARTTIME >= params.fromDate -- yesterday at
    -- midnight
AND bk.STARTTIME < params.toDate --
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME

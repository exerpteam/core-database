-- The extract is extracted from Exerp on 2026-02-08
-- ST-8517
SELECT
    p.EXTERNAL_ID                                                        AS "Member ID",
    c.NAME                                                            AS "Center",
    TO_CHAR(longtodateTZ(t1.CHECKIN_TIME, 'Europe/London'),'HH24:MI')    AS "Start Time",
    TO_CHAR(longtodateTZ(t1.CHECKOUT_TIME, 'Europe/London'),'HH24:MI')   AS "End Time",
    t1.DURATION                                         AS "Checkin Duration",
    TO_CHAR(longtodateTZ(T1.CHECKIN_TIME, 'Europe/London'),'dd/MM/YYYY') AS "Date"
FROM
    (
        WITH
            PARAMS AS
            (
                SELECT
                    :Date_From               AS DATEFROM,
                    :Date_To+24*3600*1000 AS DATETO
                FROM
                    DUAL
            )
        SELECT
            --TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'),'dd/MM/YYYY HH24:MI:SS') AS
            -- CHECK_IN_timestamp,
            --TO_CHAR(longtodateTZ(ci.CHECKOUT_TIME, 'Europe/London'),'dd/MM/YYYY HH24:MI:SS') AS
            -- CHECK_OUT_timestamp,
            ci.PERSON_CENTER,
            ci.PERSON_ID,
            ci.CHECKIN_CENTER,
            ci.CHECKIN_TIME,
            ci.CHECKOUT_TIME,
            TRUNC((ci.CHECKOUT_TIME-ci.CHECKIN_TIME)/(1000*60),2) AS DURATION
        FROM
            checkins ci
        CROSS JOIN
            PARAMS
        WHERE
            ci.CHECKIN_CENTER IN (:center)
			AND ci.checkin_result <> 3
            AND ci.CHECKOUT_TIME-ci.CHECKIN_TIME BETWEEN (:Checkin_Duration_From * 60 * 1000) and (:Checkin_Duration_To * 60 * 1000)
        AND ci.CHECKIN_TIME BETWEEN PARAMS.DATEFROM AND PARAMS.DATETO ) t1
JOIN
    persons p
ON
    t1.PERSON_CENTER = p.CENTER
AND t1.PERSON_ID = p.ID
JOIN
    CENTERS c
ON
    c.ID = t1.CHECKIN_CENTER

WHERE  p.persontype != 2
AND NOT EXISTS
                (
                        SELECT
                                1
                        FROM
                                SUBSCRIPTIONS s
                        JOIN
                                PRODUCTS pr ON s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND s.SUBSCRIPTIONTYPE_ID = pr.ID AND pr.GLOBALID = 'CONTRACTORS'
                        WHERE
                                s.OWNER_CENTER = p.CENTER
                                AND s.OWNER_ID = p.ID
                                AND s.STATE IN (2,4,8)
                        
                )
ORDER BY
    t1.CHECKOUT_TIME DESC
    
  
    
SELECT
CHECKIN_CENTER,
    MEMFIRSTNAME AS "FIRST NAME",
    MEMLASTNAME AS "LAST NAME",
    TO_CHAR(TO_DATE(CHKIN_TIME,'YYYY-MM-DD'),'MM/DD/YYYY')                   AS "CHECK IN DATE",
    TO_CHAR(TO_TIMESTAMP(CHKIN_TIME,'YYYY-MM-DD HH24:MI:SS'),'FMHH12:MI AM') AS "CHECK IN TIME",
    IDENTITY_METHOD AS "CHECK IN METHOD",
    CHECKIN_RESULT AS "CHECK IN STATUS",
    STATUS AS "MEMBER STATUS",
    NULL AS "CHECK IN NOTE"
FROM
    (
        WITH
            params AS
            (
                SELECT
                    c.id   AS CENTERID,
                    c.name AS center_name,
                    cast(datetolongTZ(to_char(TO_date($$FROMDATE$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) as BIGINT) AS FROMDATE,
                    cast(datetolongTZ(to_char(TO_date($$TODATE$$,'YYYY-MM-DD HH24:MI:SS')+INTERVAL'1 DAYS','YYYY-MM-DD HH24:MI:SS'), c.time_zone)-1 as BIGINT)AS TODATE
                FROM
                    centers c
                WHERE c.id IN ($$scope$$)
            )
        SELECT
            P.FIRSTNAME                                                                MEMFIRSTNAME,
            P.LASTNAME                                                                  MEMLASTNAME,
            TO_CHAR(LONGTODATEC(CHK.CHECKIN_TIME,CHK.CHECKIN_CENTER), 'YYYY-MM-DD HH24:MI') AS
            CHKIN_TIME,
            CHK.CHECKIN_CENTER,
            CASE
                WHEN CHK.IDENTITY_METHOD=1
                THEN 'BARCODE'
                WHEN CHK.IDENTITY_METHOD=2
                THEN 'MAGNETIC CARD'
                WHEN CHK.IDENTITY_METHOD=4
                THEN 'RF CARD'
                WHEN CHK.IDENTITY_METHOD=5
                THEN 'PIN'
                WHEN CHK.IDENTITY_METHOD=6
                THEN 'ANTI DROWN'
                WHEN CHK.IDENTITY_METHOD=7
                THEN 'QR CODE'
                WHEN CHK.IDENTITY_METHOD=8
                THEN 'EXTERNAL SYSTEM'
                ELSE 'UNKNOWN'
            END AS IDENTITY_METHOD,
            CASE 
            WHEN P.STATUS=0 THEN 'LEAD'
            WHEN P.STATUS=1 THEN 'ACTIVE'
            WHEN P.STATUS=2 THEN 'INACTIVE'
            WHEN P.STATUS=3 THEN 'TEMPORARY INACTIVE'
            WHEN P.STATUS=4 THEN 'TRANSFERRED'
            WHEN P.STATUS=5 THEN 'DUPLICATE'
            WHEN P.STATUS=6 THEN 'PROSPECT'
            WHEN P.STATUS=7 THEN 'DELETED'
            WHEN P.STATUS=8 THEN 'Anonymized'
            WHEN P.STATUS=9 THEN 'Contact'
            ELSE 'UNKNOWN'
            END AS STATUS,
            CASE 
            WHEN CHECKIN_RESULT = 0 THEN 'UNDEFINED'
            WHEN CHECKIN_RESULT = 1 THEN 'ACCESS GRANTED'
            WHEN CHECKIN_RESULT = 2 THEN 'PRESENCE REGISTERED'
            WHEN CHECKIN_RESULT = 3 THEN 'ACCESS DENIED'
            END AS CHECKIN_RESULT,
                fromdate,
            todate
        FROM
            PARAMS
        JOIN
            CHECKINS CHK
        ON
            CENTERID=CHK.CHECKIN_CENTER
        JOIN
            PERSONS P
        ON
            P.CENTER = CHK.PERSON_CENTER
        AND P.ID=CHK.PERSON_ID

        where CHK.checkin_time BETWEEN FROMDATE AND TODATE
        )T
-- This is the version from 2026-02-05
--  
SELECT
    WEEK,
    TID,
    "Mandag", "Tirsdag",
    "Onsdag",
    "Torsdag",
    "Fredag",
    "Lørdag",
    "Søndag"
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    TO_CHAR(longToDate(book.STARTTIME),'WW') "WEEK",
                    TO_CHAR(longToDate(book.STARTTIME),'D') "DAY",
                    TO_CHAR(longToDate(book.STARTTIME),'hh24:MI') "TID",
                    TO_CHAR(longToDate(book.STARTTIME),'DAY') || book.NAME || ', ' || COUNT(par.CENTER) || ' deltagare, ' || SUBSTR(p.FIRSTNAME,0,1) || SUBSTR(p.LASTNAME,0,1) INFO,
                    book.NAME
                FROM
                    (
                        SELECT
                            1390345200000                AS STARTWEEK,
                            1390777200000 + 24*3600*1000 AS ENDWEEK
                        FROM
                            dual
                    )
                    params,
                    FW.BOOKINGS book
                LEFT JOIN FW.PARTICIPATIONS par
                ON
                    book.CENTER = par.BOOKING_CENTER
                    AND book.ID = par.BOOKING_ID
                    AND par.STATE != 'CANCELLED'
                JOIN FW.CENTERS c
                ON
                    c.ID = book.CENTER
                LEFT JOIN FW.STAFF_USAGE su
                ON
                    su.BOOKING_CENTER = book.CENTER
                    AND su.BOOKING_ID = book.ID
                LEFT JOIN FW.PERSONS p
                ON
                    p.CENTER = su.PERSON_CENTER
                    AND p.ID = su.PERSON_ID
                WHERE
                    book.STATE = 'ACTIVE'
                    AND book.CLASS_CAPACITY > 3
                    AND book.STARTTIME BETWEEN params.startweek AND params.endweek
                    AND book.CENTER IN (102)
                GROUP BY
                    book.CENTER,
                    TO_CHAR(longToDate(book.STARTTIME),'hh24:MI'),
                    TO_CHAR(longToDate(book.STARTTIME),'WW'),
                    TO_CHAR(longToDate(book.STARTTIME),'DAY'),
                    book.ID,
                    TO_CHAR(longToDate(book.STARTTIME),'DD'),
                    TO_CHAR(longToDate(book.STARTTIME),'D'),
                    c.SHORTNAME,
                    book.NAME,
                    p.FIRSTNAME,
                    p.LASTNAME,
                    book.NAME
                HAVING
                    COUNT(par.CENTER) < 100000
            )
            pivot (MIN(INFO) FOR DAY IN ( 1 AS "Mandag",2 AS "Tirsdag",3 AS "Onsdag",4 AS "Torsdag",5 AS "Fredag",6 AS "Lørdag",7 AS "Søndag") )
        ORDER BY
            TID
    )
-- This is the version from 2026-02-05
-- Ticket 37296
SELECT
    C.NAME || ' (' || C.ID || ')' AS "CENTER",
    week                          AS "WEEK",
    tid                           AS "TID",
    "Mandag",
    "Tirsdag",
    "Onsdag",
    "Torsdag",
    "Fredag",
    "Lørdag",
    "Søndag"
FROM
    (   SELECT
            *,
            MIN(CASE WHEN "day" = 1
                    THEN INFO
                    ELSE NULL
            END) AS "Mandag",
            MIN(CASE WHEN "day" = 2
                    THEN INFO
                    ELSE NULL
            END) AS "Tirsdag",
            MIN(CASE WHEN "day" = 3
                    THEN INFO
                    ELSE NULL
            END) AS "Onsdag",
            MIN(CASE WHEN "day" = 4
                    THEN INFO
                    ELSE NULL
            END) AS "Torsdag",
            MIN(CASE WHEN "day" = 5
                    THEN INFO
                    ELSE NULL
            END) AS "Fredag",
            MIN(CASE WHEN "day" = 6
                    THEN INFO
                    ELSE NULL
            END) AS "Lørdag",
            MIN(CASE WHEN "day" = 7
                    THEN INFO
                    ELSE NULL
            END) AS "Søndag"
        FROM
            (   SELECT
                    book.center,
                    TO_CHAR(longToDate(book.STARTTIME), 'IW')       AS week,
                    extract(isodow FROM longToDate(book.STARTTIME)) AS "day",
                    TO_CHAR(longToDate(book.STARTTIME), 'hh24:MI')  AS tid,
                    book.NAME || ', ' ||SUBSTR(p.FIRSTNAME, 0, 1) || SUBSTR(p.LASTNAME, 0, 1) ||
                    ', ' || COUNT(par.CENTER) || ' deltagare' AS INFO,
                    book.NAME
                FROM
                    (   SELECT
                            :startDate                  AS STARTWEEK,
                            :endDate + 24 * 3600 * 1000 AS ENDWEEK) params,
                    BOOKINGS                               book
                LEFT JOIN
                    PARTICIPATIONS par
                    ON  book.CENTER = par.BOOKING_CENTER
                        AND book.ID = par.BOOKING_ID
                        AND par.STATE != 'CANCELLED'
                JOIN
                    CENTERS c
                    ON  c.ID = book.CENTER
                LEFT JOIN
                    STAFF_USAGE su
                    ON  su.BOOKING_CENTER = book.CENTER
                        AND su.BOOKING_ID = book.ID
                LEFT JOIN
                    PERSONS p
                    ON  p.CENTER = su.PERSON_CENTER
                        AND p.ID = su.PERSON_ID
                WHERE
                    book.STATE = 'ACTIVE'
                    AND book.CLASS_CAPACITY > 3
                    AND book.STARTTIME BETWEEN params.startweek AND params.endweek
                    AND book.CENTER = :center
                GROUP BY book.CENTER,
                    book.NAME,
                    book.ID,
                    TO_CHAR(longToDate(book.STARTTIME), 'hh24:MI'),
                    TO_CHAR(longToDate(book.STARTTIME), 'IW'),
                    extract(dow FROM longToDate(book.STARTTIME)),
                    c.SHORTNAME,
                    p.FIRSTNAME,
                    p.LASTNAME
                HAVING
                    COUNT(par.CENTER) < :limit) t
        GROUP BY center,
            week,
            DAY,
            tid,
            info,
            NAME
        ORDER BY
            week,
            tid) SQ,
    CENTERS      C
WHERE
    SQ.CENTER = C.ID
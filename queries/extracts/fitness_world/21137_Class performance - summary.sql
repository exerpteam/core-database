-- This is the version from 2026-02-05
-- Ticket 37296 - summed
SELECT
    center,
	id,
    week,
    SUM(
        CASE
            WHEN participants < :limit
            THEN 1
            ELSE 0
        END) under_limit,
    SUM(
        CASE
            WHEN participants >= :limit
            THEN 1
            ELSE 0
        END) over_and_on_limit
FROM
    (
        SELECT
            c.SHORTNAME center,
			c.id,
            TO_CHAR(longToDate(book.STARTTIME),'IW') week,
            COUNT(par.CENTER) participants
        FROM
            BOOKINGS book
        LEFT JOIN PARTICIPATIONS par
        ON
            book.CENTER = par.BOOKING_CENTER
            AND book.ID = par.BOOKING_ID
            AND par.STATE != 'CANCELLED'
        JOIN CENTERS c
        ON
            c.ID = book.CENTER
        WHERE
            book.STARTTIME BETWEEN :fromDate and :toDate + (1000*60*60*24)
            AND book.CENTER in (:scope)
            and book.STATE = 'ACTIVE'
            AND book.CLASS_CAPACITY > 3
            
        GROUP BY
            book.CENTER,
            book.ID,
            TO_CHAR(longToDate(book.STARTTIME),'IW'),
            c.SHORTNAME,
			c.id
    ) t
GROUP BY
    center,
	id,
    week
ORDER BY
    center,
    week

-- This is the version from 2026-02-05
--  
SELECT
    par.CENTER              participation_center,
    p.CENTER || 'p' || p.ID pid,
    act.NAME activity_name,
    longToDate(book.STARTTIME) BOOK_START,
    longToDate(book.STOPTIME)  BOOK_END
FROM
    PARTICIPATIONS par
JOIN
    BOOKINGS book
ON
    book.CENTER = par.BOOKING_CENTER
    AND book.id = par.BOOKING_ID
JOIN
    ACTIVITY act
ON
    act.ID = book.ACTIVITY
JOIN
    PERSONS p
ON
    p.CENTER = par.PARTICIPANT_CENTER
    AND p.ID = par.PARTICIPANT_ID
WHERE
    par.STATE IN ('PARTICIPATION')
    and act.id not in (15141,11541)
    and par.CENTER in ($$scope$$)
    and book.STARTTIME between $$startTime$$ and $$endTime$$
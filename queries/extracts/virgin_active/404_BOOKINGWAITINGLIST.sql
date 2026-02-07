/*
The in waiting list id is tricky since we don't have a specific table for this, only a que number and a class capacity
*/

SELECT

    '?' "InWaitingID",
    p.EXTERNAL_ID "PersonID",
    book.CENTER || 'book' || book.ID "BookingProductID",
    longToDate(book.STARTTIME) "BookingStart",
    longToDate(book.STOPTIME) "BookingEnd",
    longToDate(book.STARTTIME) "BookingDate",
    'EXERP' "SourceSystem",
    par.CENTER || 'par' || par.ID "ExtRef"
FROM
    PARTICIPATIONS par
JOIN PERSONS op
ON
    op.CENTER = par.PARTICIPANT_CENTER
    AND op.ID = par.PARTICIPANT_ID
JOIN PERSONS p
ON
    p.CENTER = op.CURRENT_PERSON_CENTER
    AND p.ID = op.CURRENT_PERSON_ID
JOIN BOOKINGS book
ON
    book.CENTER = par.BOOKING_CENTER
    AND book.ID = par.BOOKING_ID
SELECT
    center,id,CANCELLATION_REASON,1
FROM
    bookings
WHERE
    instr(bookings.CANCELLATION_REASON,CHR(13)) = 1
    and center = 41
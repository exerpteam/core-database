-- The extract is extracted from Exerp on 2026-02-08
--  
Select
    TO_CHAR(longToDate(book.STARTTIME), 'DY') DAY_OF_WEEK
from
    bookings book

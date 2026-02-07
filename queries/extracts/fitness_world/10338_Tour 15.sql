-- This is the version from 2026-02-05
--  
SELECT
    part.participant_center||'p'||part.participant_id as customer,
    count(*) as all_classes
FROM
    fw.participations part
JOIN fw.BOOKINGS book
ON
    book.center=part.BOOKING_CENTER
    AND book.id=part.BOOKING_ID
JOIN
    (
        SELECT
            sub.OWNER_CENTER,
            sub.OWNER_ID
        FROM
            fw.SUBSCRIPTIONS sub
        JOIN fw.PRODUCTS pd
        ON
            pd.CENTER=sub.SUBSCRIPTIONTYPE_CENTER
            AND pd.id=sub.SUBSCRIPTIONTYPE_ID
            AND pd.GLOBALID='EVENT_TOURDEFRANCE'
        WHERE
            sub.state in (2,4)
    )
    TourCount
ON
    TourCount.OWNER_CENTER = part.PARTICIPANT_CENTER
    AND TourCount.OWNER_ID = part.PARTICIPANT_ID
WHERE
    part.START_TIME >= datetolong('2011-05-30 00:00')
and part.START_TIME < datetolong('2011-08-08 00:00')
AND part.STATE = 'PARTICIPATION'
AND
    (
        (book.NAME LIKE 'Bodybike%')
        OR
        (book.NAME LIKE 'Spinning%')
        OR
        (book.NAME LIKE 'BikeFit%')
        OR
        (book.NAME LIKE 'Tour%')
	OR
        (book.NAME LIKE 'Landevej%')
        OR
        (book.NAME LIKE 'Event - Bike%')
        OR
        (book.NAME LIKE 'Event, betalt - BikeFit')
        OR
        (book.NAME LIKE 'Junior Bodybike')
        OR
        (book.NAME LIKE 'Quick Bodybike')

    )
GROUP BY
    part.participant_center,
    part.participant_id
having count(*) >=15 
ORDER BY
    part.participant_center,
    part.participant_id


-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    part.center,
    TO_CHAR(longtodate(part.START_TIME), 'IW') AS WEEK,
    COUNT(*) AS NB,
    COUNT(TourCount.OWNER_CENTER) AS TOURCOUNT,
    TO_CHAR(ROUND(SUM (
        CASE
            WHEN TourCount.OWNER_CENTER IS NOT NULL
            THEN 1
            ELSE 0
        END) * 100 / COUNT(*), 2), '90.00') || ' %' AS TDF
FROM
    fw.participations part
JOIN fw.BOOKINGS book
ON
    book.center=part.BOOKING_CENTER
    AND book.id=part.BOOKING_ID
LEFT JOIN
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
 part.START_TIME >= :date_from
and part.START_TIME <= :date_to  + 24 * 3600 * 1000

    AND part.STATE = 'PARTICIPATION'
    AND
    (
        (
            book.NAME LIKE 'Bodybike%'
        )
        OR
        (
            book.NAME LIKE 'Spinning%'
        )
	 OR
        (
            book.NAME LIKE 'BikeFit%'
        )
        OR
        (
            book.NAME LIKE 'Tour%'
        )
		OR
        (
            book.NAME LIKE 'landevej%'
        )
    )
GROUP BY
    part.center,
    TO_CHAR(longtodate(part.START_TIME), 'IW')
ORDER BY
    1,2
-- The extract is extracted from Exerp on 2026-02-08
--  
Select
	DAY_OF_WEEK,              
    TIME_OF_DAY,              
    ACTIVITY_NAME,            
    COUNT(*) classes,         
    AVG(CLASS_CAPACITY) avgCapacity,          
    MAX(antal) maxParticipations,             
    MIN(antal) minParticipations,             
    ROUND(AVG(antal), 2) avgParticipations	  	
FROM
    (
        SELECT
            book.CENTER,
			club.NAME clubName,
            act.ID,
            act.NAME AS ACTIVITY_NAME,
            TO_CHAR(longToDate(book.STARTTIME), 'YYYY-MM-DD HH24:MI')BOOKING_START_TIME,
            TO_CHAR(longToDate(book.STARTTIME), 'DY') DAY_OF_WEEK,
            TO_CHAR(longToDate(book.STARTTIME), 'HH24:MI') TIME_OF_DAY,
            book.CLASS_CAPACITY,
            par.STATE,
            COUNT(*) antal,
            ROUND(COUNT(*) / book.CLASS_CAPACITY * 100) as load
        FROM
            BOOKINGS book
        JOIN ACTIVITY act
        ON
            act.id = book.ACTIVITY
 		JOIN CENTERS club
        ON
            book.CENTER = club.ID
        LEFT JOIN PARTICIPATIONS par
        ON
            book.CENTER = par.BOOKING_CENTER
            AND book.id = par.BOOKING_ID
        WHERE
            act.ACTIVITY_TYPE = 2
            AND book.CENTER in (:scope)
            AND book.STARTTIME > :datefrom
            AND book.STARTTIME < :dateto + 60*60*24*1000
            AND par.STATE <> 'CANCELLED'
			and act.name not in ('Squash', 'Beauty Angel')
        GROUP BY
            book.CENTER, club.NAME,
            act.ID,
            act.NAME ,
            longToDate(book.STARTTIME),
            book.CLASS_CAPACITY,
            par.STATE
        ORDER BY
            1,2,5,6
    ) t
group by     
	CENTER, clubname,
    ACTIVITY_NAME,
	DAY_OF_WEEK,
    TIME_OF_DAY

ORDER BY
    1,2,4,5,6,7,8        

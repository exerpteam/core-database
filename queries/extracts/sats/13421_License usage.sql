SELECT
    *
FROM
    (
        SELECT
            'CourtBooking' feature,
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON') MON
        FROM
            BOOKINGS book
        JOIN CENTERS center
        ON
            book.center = center.id
        JOIN ACTIVITIES_NEW act
        ON
            act.id = book.ACTIVITY
        WHERE
            act.ACTIVITY_TYPE = 3
            AND book.STARTTIME > :FromDate
            AND book.STARTTIME < :ToDate + 1000*60*60*24
        GROUP BY
            'CourtBooking',
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON')
        UNION ALL
        SELECT
            'StaffBooking' feature,
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON') MON
        FROM
            BOOKINGS book
        JOIN CENTERS center
        ON
            book.center = center.id
        JOIN ACTIVITIES_NEW act
        ON
            act.id = book.ACTIVITY
        WHERE
            act.ACTIVITY_TYPE = 4
            AND book.STARTTIME > :FromDate
            AND book.STARTTIME < :ToDate + 1000*60*60*24
        GROUP BY
            'CourtBooking',
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON')
        UNION ALL
        SELECT
            'ClassBooking' feature,
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON') MON
        FROM
            BOOKINGS book
        JOIN CENTERS center
        ON
            book.center = center.id
        JOIN ACTIVITIES_NEW act
        ON
            act.id = book.ACTIVITY
        WHERE
            act.ACTIVITY_TYPE = 2
            AND book.STARTTIME > :FromDate
            AND book.STARTTIME < :ToDate + 1000*60*60*24
        GROUP BY
            'ClassBooking',
            center.COUNTRY,
            book.center,
            TO_CHAR(longtodate(book.STARTTIME), 'MON')
        UNION ALL
        SELECT
            'Base' feature,
            center.COUNTRY,
            checkin.center,
            TO_CHAR(TO_DATE('1970-01-01','yyyy-mm-dd') + checkin.CHECKIN_TIME/(24*3600*1000) + 2/24, 'MON') MON
        FROM
            CHECKIN_LOG checkin
        JOIN CENTERS center
        ON
            checkin.center = center.id
        WHERE
            checkin.CHECKIN_TIME > :FromDate
            AND checkin.CHECKIN_TIME < :ToDate + 1000*60*60*24
        GROUP BY
            'Base',
            center.COUNTRY,
            checkin.center,
            TO_CHAR(TO_DATE('1970-01-01','yyyy-mm-dd') + checkin.CHECKIN_TIME/(24*3600*1000) + 2/24, 'MON')
    )
    PIVOT ( COUNT(center) FOR MON IN ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC') )

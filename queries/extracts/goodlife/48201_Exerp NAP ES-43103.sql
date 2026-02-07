SELECT DISTINCT
    longtodateTZ(m.senttime, 'America/Toronto')     AS m_time,
    m.center,
    m.id,
m.subid
   
FROM
    messages m
WHERE
    ((
            m.center = 250
        AND m.id = 132408)
    OR  (
            m.center = 326
        AND m.id = 9603))
AND m.subject LIKE 'Booking Cancelled%'
and m.senttime >= datetolongTZ('2024-05-01 01:00','America/Toronto')
Group by
m.center,
m.id,
m.senttime,
m.subid
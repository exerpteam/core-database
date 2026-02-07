-- This is the version from 2026-02-05
--  
WITH params AS (
    SELECT
        $$startdate$$ AS PeriodStart,
        ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd
)

SELECT
    bo.center                              AS "Center ID",
    c.shortname                            AS "Center name",
    br.id                                  AS "Resource ID",
    br.name                                AS "Room / Resource name",

    -- YEAR & MONTH
    EXTRACT(YEAR  FROM longtodateC(bo.starttime, bo.center)) AS "Year",
    EXTRACT(MONTH FROM longtodateC(bo.starttime, bo.center)) AS "Month",

    -- QUARTER (Q1–Q4)
    'Q' || CEIL(EXTRACT(MONTH FROM longtodateC(bo.starttime, bo.center)) / 3.0)
                                            AS "Quarter",

    COUNT(*)                                AS "Number of classes"
FROM
    BOOKINGS bo
JOIN params p
        ON bo.starttime BETWEEN p.PeriodStart AND p.PeriodEnd
       AND bo.center IN ($$scope$$)
       AND bo.state IN ('ACTIVE','PLANNED')
JOIN ACTIVITY ac
        ON ac.id = bo.activity
       AND ac.activity_type = 2
JOIN BOOKING_RESOURCE_USAGE bru
        ON bru.booking_center = bo.center
       AND bru.booking_id = bo.id
       AND bru.state = 'ACTIVE'
JOIN BOOKING_RESOURCES br
        ON br.center = bru.booking_resource_center
       AND br.id = bru.booking_resource_id
JOIN CENTERS c
        ON c.id = bo.center
GROUP BY
    bo.center, c.shortname,
    br.id, br.name,
    EXTRACT(YEAR  FROM longtodateC(bo.starttime, bo.center)),
    EXTRACT(MONTH FROM longtodateC(bo.starttime, bo.center)),
    CEIL(EXTRACT(MONTH FROM longtodateC(bo.starttime, bo.center)) / 3.0)
ORDER BY
    bo.center,
    "Year",
    "Month",
    br.name;

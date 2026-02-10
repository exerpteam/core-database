-- The extract is extracted from Exerp on 2026-02-08
-- This extract has been made to make sure  the Replace functionality does not create corrupted data on the Staff Usage. As long as it returns nothing we are good
WITH
PARAMS AS
(
        SELECT
                /*+ materialize */
                datetolongC(to_char(to_date(getcentertime(c.id),'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),c.ID)  AS FROMDATE,                
                c.id AS CENTER_ID
        FROM
                centers c
)
SELECT
        b.center,
        b.id,
        COUNT(*)
FROM
        goodlife.bookings b
JOIN params
        ON params.CENTER_ID = b.center
JOIN
        goodlife.staff_usage su
        ON
                su.booking_center = b.center
                AND su.booking_id = b.id
JOIN
        activity a
        ON
                b.activity = a.id
JOIN
        activity_staff_configurations acs
        ON
                acs.activity_id = a.id
WHERE
        b.starttime >= PARAMS.FROMDATE
        AND su.state = 'ACTIVE'
        AND acs.maximum_staffs = 1
GROUP BY 
        b.center,
        b.id
HAVING COUNT(*) > 1
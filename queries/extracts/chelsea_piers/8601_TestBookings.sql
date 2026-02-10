-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT			
            c.id   AS CENTER_ID,
            c.name AS center_name,
			datetolongc(TO_CHAR(to_date($$fromdate$$, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
            , c.id) AS FROM_DATE
        FROM
            centers c
             WHERE
            c.id IN ($$scope$$)
    )

SELECT id,name,starttime,semesterId
FROM chelseapiers.bookings b
JOIN
    params
ON
    b.center = center_id
WHERE b.creation_time >= params.FROM_DATE
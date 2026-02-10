-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
        SELECT
                TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') AS TODAY,
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '30 days' AS CUT_DATE,
                c.id
        FROM
                leejam.centers c
),
have_sub AS 
(
        SELECT
                s.owner_center,
                s.owner_id
        FROM leejam.subscriptions s
        JOIN params par ON par.id = s.center
        WHERE
                s.center IN (102119,101105,103107)
                AND s.start_date <= par.TODAY
                AND 
                        (
                        s.end_date IS NULL
                        OR
                        s.end_date > par.CUT_DATE
                        )
)
SELECT
        t1.*
FROM
(
        SELECT
                s.owner_center || 'p' || s.owner_id AS PERSON_ID,
                SUM(LEAST(s.end_date,par.TODAY) - s.start_date + 1) AS TOTAL_DAYS
        FROM
                have_sub hs
        JOIN
                leejam.subscriptions s ON hs.owner_center = s.owner_center AND hs.owner_id = s.owner_id
        JOIN 
                params par ON par.id = s.center
        WHERE
                s.center IN (102119,101105,103107)
                AND s.start_date <= par.TODAY
        GROUP BY 
                s.owner_center,
                s.owner_id
)  t1
                WHERE t1.TOTAL_DAYS >= 1000 AND  t1.TOTAL_DAYS < 1400 
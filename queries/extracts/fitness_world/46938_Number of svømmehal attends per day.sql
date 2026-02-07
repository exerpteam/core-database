-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-4454
SELECT
    attend   AS "Date",
    COUNT(*) AS "Attends"
FROM
    (
        SELECT
            person_center,
            person_id,
            attend
        FROM
            (
                SELECT
                    a.person_center,
                    a.person_id,
                    TO_CHAR(TRUNC(longtodatec(a.start_time, a.center)), 'YYYY-MM-dd') AS attend
                FROM
                    attends a
                JOIN
                    booking_resources br
                ON
                    br.center = a.booking_resource_center
                    AND br.id = a.booking_resource_id
                    AND br.name = 'Svømmehal'
                WHERE
                    a.person_center IN ($$Scope$$)
                    AND a.state = 'ACTIVE'
                    AND a.start_time BETWEEN ($$FromDate$$) AND (
                        $$ToDate$$) )
        GROUP BY
            person_center,
            person_id,
            attend )
GROUP BY
    attend
ORDER BY 1 asc	
	
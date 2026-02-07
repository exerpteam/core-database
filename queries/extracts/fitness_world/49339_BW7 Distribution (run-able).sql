-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-6032
WITH
    dates AS
    (
        SELECT
            $$start_date$$ + rownum -1 AS date_distribution
        FROM
            /* we just need a table larger than the list of dates */
            persons
        WHERE
            rownum <= $$end_date$$-$$start_date$$+1
    )
    ,
    centerlist AS
    (
        SELECT
            ss.OWNER_CENTER    AS id,
            MIN(ss.SALES_DATE) AS startupdate
        FROM
            SUBSCRIPTION_SALES ss
            join centers c on c.id = ss.OWNER_CENTER
            where c.CENTER_TYPE = 4
        GROUP BY
            ss.OWNER_CENTER
    )
SELECT
    TO_CHAR((dates.date_distribution), 'YYYY-MM-DD') AS "date_distribution",
    'total'   AS "type_distribution",
    COUNT(id) AS "count_distribution"

FROM
    dates ,
    centerlist c
WHERE
    c.STARTUPDATE <= dates.date_distribution
    AND c.id IN ($$scope$$)
/* old and closed clubs */
AND c.id not in (100,400,111,226,611,238,622,621,623,225,104,606,214,184)
GROUP BY
    date_distribution
ORDER BY
    date_distribution ASC
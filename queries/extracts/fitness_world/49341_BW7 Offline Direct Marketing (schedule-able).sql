-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-6033
WITH
    dates AS
    (
        SELECT
            TRUNC(exerpsysdate()) -rownum +1 AS date_offline_dm
        FROM
            /* we just need a table larger than the list of dates */
            persons
        WHERE
            rownum <= $$offset$$
    )
SELECT
    TO_CHAR((dates.date_offline_dm), 'YYYY-MM-DD') AS "date_offline_dm",
    'Flyers' "channel_offline_dm",
    0        "count_offline_dm",
    ' '       "cost_offline_dm",
    'dkk'    "currency_offline_dm"
FROM
    dates 
ORDER BY
    date_offline_dm ASC
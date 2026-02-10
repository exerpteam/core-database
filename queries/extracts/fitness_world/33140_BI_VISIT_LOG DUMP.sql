-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            dateToLong(TO_CHAR($$from_time$$, 'YYYY-MM-dd HH24:MI')) AS FROMDATE,
            dateToLong(TO_CHAR($$to_time$$, 'YYYY-MM-dd HH24:MI'))                                   AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    BI_VISIT_LOG biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
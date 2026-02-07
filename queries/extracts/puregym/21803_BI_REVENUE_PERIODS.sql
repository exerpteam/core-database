WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,0,to_date('1970-01-01','yyyyy-MM-dd'),(TRUNC(SYSDATE)-$$offset$$)) AS FROMDATE,
            (TRUNC(SYSDATE+1))                                 AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    BI_REVENUE_PERIODS biview
WHERE
    biview.BOOK_DATE BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
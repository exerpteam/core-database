
WITH
    params AS
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH:MI'
                    ) )
            END                                                                       AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH:MI') ) AS TODATE
    )
SELECT
    biview.*
FROM
    params ,
    BI_CLIPCARDS biview
WHERE
    biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
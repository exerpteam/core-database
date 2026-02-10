-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'
                    ) )
            END                                                                       AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     BI_SALES_LOG biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 and biview."CENTER_ID" in ($$scope$$)
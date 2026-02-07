 WITH
     params AS
     (
         SELECT
              CAST(CASE
            WHEN $$offset$$ = -1
            THEN 0
            ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI') )
        END  AS BIGINT) AS FROMDATE,
        CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS BIGINT) AS TODATE
         
     )
 SELECT
     biview.*
 FROM
     params,
     BI_PERSON_DETAILS biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

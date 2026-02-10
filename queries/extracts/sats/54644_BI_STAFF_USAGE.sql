-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
            CAST(CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'
                    ) )
            END  AS BIGINT) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS BIGINT) AS TODATE
         
     )
 -- Exclude SUBSTITUTE_OF_PERSON ST-8505
 SELECT
     biview."STAFF_USAGE_ID",
         biview."BOOKING_ID",
         biview."CENTER_ID",
         biview."PERSON_ID",
         biview."STATE",
         biview."START_DATE_TIME",
         biview."STOP_DATE_TIME",
         biview."SALARY",
         biview."ETS"
 FROM
     params,
     BI_STAFF_USAGE biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

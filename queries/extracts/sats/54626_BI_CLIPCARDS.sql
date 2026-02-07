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
 -- Exclude COMPANY_ID ST-8505
 SELECT
         biview."CLIPCARD_ID",
         biview."PERSON_ID",
         biview."CLIPS_LEFT",
         biview."CLIPS_INITIAL",
         biview."SALES_LINE_ID",
         biview."VALID_FROM_DATE",
         biview."VALID_UNTIL_DATE",
         biview."BLOCKED",
         biview."CANCELLED",
         biview."CANCELLATION_TIME",
         biview."ASSIGNED_EMPLOYEE_ID",
         biview."COMMENT",
         biview."CENTER_ID",
     biview."ETS"
         --biview.*
 FROM
     params,BI_CLIPCARDS biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

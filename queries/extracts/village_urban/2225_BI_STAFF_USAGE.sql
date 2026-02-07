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
     BI_STAFF_USAGE biview
  WHERE
     biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
 UNION ALL
 SELECT
 NULL AS "STAFF_USAGE_ID",
 NULL AS "BOOKING_ID",
 NULL AS "CENTER_ID",
 NULL AS "PERSON_ID",
 NULL AS "STATE",
 NULL AS "START_DATE_TIME",
 NULL AS "STOP_DATE_TIME",
 NULL AS "SALARY",
 NULL AS "ETS"

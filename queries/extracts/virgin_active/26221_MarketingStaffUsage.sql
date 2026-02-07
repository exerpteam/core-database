 WITH
     params AS
     (
         SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
     )
 SELECT
 "STAFF_USAGE_ID",
 "BOOKING_ID",
 "CENTER_ID",
 "PERSON_ID",
 "STATE",
 "START_DATE_TIME",
 "STOP_DATE_TIME",
 "SALARY"
 FROM
     params,
     BI_STAFF_USAGE biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
     and biview."CENTER_ID" in ($$scope$$)
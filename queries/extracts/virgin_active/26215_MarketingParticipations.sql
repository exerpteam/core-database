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
 "PARTICIPATION_ID",
 "BOOKING_ID",
 "CENTER_ID",
 "PERSON_ID",
 "CREATION_DATE_TIME",
 "STATE",
 "USER_INTERFACE_TYPE",
 "SHOW_UP_TIME",
 "SHOW_UP_INTERFACE_TYPE",
 "SHOWUP_USING_CARD",
 "CANCEL_TIME",
 "CANCEL_INTERFACE_TYPE",
 "CANCEL_REASON",
 "WAS_ON_WAITING_LIST"
 FROM
     params,BI_PARTICIPATIONS biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
         and biview."CENTER_ID" in ($$scope$$)

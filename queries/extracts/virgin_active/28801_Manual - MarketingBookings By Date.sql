-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 "BOOKING_ID",
 "NAME",
 "CENTER_ID",
 "ACTIVITY_ID",
 "COLOR",
 "START_DATE_TIME",
 "STOP_DATE_TIME",
 "CREATION_DATE_TIME",
 "STATE",
 "CLASS_CAPACITY",
 "WAITING_LIST_CAPACITY",
 "CANCEL_DATE_TIME",
 replace(replace(replace(replace(
 replace("CANCEL_REASON",CHR(13), '[CR]'), CHR(10), '[LF]'),';','')
 ,'"','[qt]'), '''' , '') AS CANCEL_REASON
 FROM
     BI_BOOKINGS biview
 WHERE
     longtodateC(biview."ETS", biview."CENTER_ID") BETWEEN $$FROMDATE$$ AND $$TODATE$$
         and biview."CENTER_ID" in ($$scope$$)

SELECT
biview."BOOKING_ID",
biview."NAME",
biview."CENTER_ID",
biview."ACTIVITY_ID",
biview."COLOR",
biview."START_DATE_TIME",
biview."STOP_DATE_TIME",
biview."CREATION_DATE_TIME",
biview."STATE",
biview."CLASS_CAPACITY",
biview."WAITING_LIST_CAPACITY",
biview."CANCEL_DATE_TIME",
replace(biview."CANCEL_REASON",E'\n','') AS "CANCEL_REASON",
biview."ETS"
FROM
    BI_BOOKINGS biview
WHERE
    biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000   
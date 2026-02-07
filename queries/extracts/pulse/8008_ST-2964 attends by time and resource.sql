WITH
    recursive dates AS
    (
        SELECT
            longtodate($$from_date$$)                 AS date_inc,
            TO_CHAR(longtodate($$from_date$$) ,'DAY') AS date_day
        UNION ALL
        SELECT
            d.date_inc + interval '1 day'                AS date_inc,
            TO_CHAR(d.date_inc + interval '1 day','DAY') AS date_day
        FROM
            dates d
        WHERE
            d.date_inc + interval '1 day' < longtodate($$to_date$$)
    )
    ,
    hours AS
    (
        SELECT
            0 AS hour_num
        UNION ALL
        SELECT
            h.hour_num +1 AS hour_num
        FROM
            hours h
        WHERE
            h.hour_num +1 < 24
    )
    ,
    att AS
    (
        /*+ materialize  */
        SELECT
            att.id,
            -- Reason subtract 1 hour is that floor timestamp does with GMT need to match with UK
            -- time
            TRUNC((att.START_TIME-(floor(att.START_TIME/(1000*60*60*24))*1000*60*60*24-1000*60*60))
            /3600000)                                                            AS att_hour,
            longtodateC(att.START_TIME, att.center) AS att_date,
            att.BOOKING_RESOURCE_CENTER,
            att.BOOKING_RESOURCE_ID
        FROM
            ATTENDS att
        WHERE
            att.START_TIME BETWEEN $$from_date$$ AND $$to_date$$
        AND att.center IN ($$scope$$)
    )
SELECT
    br.CENTER                                         AS CENTER_ID,
    br.NAME                                           AS RESOURCE_NAME,
    dates.date_inc                                    AS SWIPE_DATE,
    date_day                                          AS SWIPE_DAY,
    hours.hour_num||':00-'||(hours.hour_num+1)||':00' AS SWIPE_TIME,
    COUNT(att.*)                                     AS SWIPE_COUNT
FROM
    BOOKING_RESOURCES br
CROSS JOIN
    dates
CROSS JOIN
    hours
LEFT JOIN
    att
ON
    att_hour = hours.hour_num
AND att_date = dates.date_inc
AND att.BOOKING_RESOURCE_CENTER = br.center
AND att.BOOKING_RESOURCE_ID = br.id
WHERE
    br.center IN ($$scope$$)
AND br.ATTENDABLE =true
AND br.STATE = 'ACTIVE'
GROUP BY
    br.CENTER,
    br.NAME,
    dates.date_inc,
    date_day,
    hours.hour_num
ORDER BY
    br.CENTER,
    br.NAME,
    dates.date_inc,
    hour_num
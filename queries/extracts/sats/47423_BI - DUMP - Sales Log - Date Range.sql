SELECT
    biview.*
FROM
    BI_SALES_LOG biview
WHERE
    biview."ETS" BETWEEN (($$from_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000 AND ((
            $$to_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000
             and CENTER_ID IN ($$Scope$$)
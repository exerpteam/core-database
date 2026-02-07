SELECT
    biview.*
FROM
    BI_DAILY_MEMBER_STATE biview
WHERE
    biview."ETS" >= (($$from_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000 
AND biview."ETS" < (($$to_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000
    AND biview."CENTER_ID" in ($$scope$$)
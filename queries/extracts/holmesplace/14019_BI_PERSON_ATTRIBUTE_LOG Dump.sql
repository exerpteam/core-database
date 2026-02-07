SELECT
    biview.*
FROM
    BI_PERSON_ATTRIBUTE_LOG biview
WHERE
    biview."ETS"  >= (($$from_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000 
	AND biview."ETS" < (($$to_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000

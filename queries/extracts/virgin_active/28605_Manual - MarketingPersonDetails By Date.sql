SELECT

PERSON_ID,
replace(replace(replace(replace(replace(ADDRESS1,CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS ADDRESS1,
replace(replace(replace(replace(replace(ADDRESS2,CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS ADDRESS2,
replace(replace(replace(replace(replace(ADDRESS3,CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS ADDRESS3,
WORK_PHONE,
MOBILE_PHONE,
HOME_PHONE,
EMAIL,
CENTER_ID

FROM 
	BI_PERSON_DETAILS biview
WHERE
    (to_date('19700101', 'YYYYMMDD') 
+ ( 1 / 24 / 60 / 60 / 1000) 
* biview.ETS) BETWEEN $$FROMDATE$$ AND $$TODATE$$
	and biview.CENTER_ID in ($$scope$$)
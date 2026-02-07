SELECT PERSON_ID,
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
 CENTER_ID IN (76,
405,
408,
410,
415,
421,
422,
425,
437,
438,
452,
953,
954,
955)
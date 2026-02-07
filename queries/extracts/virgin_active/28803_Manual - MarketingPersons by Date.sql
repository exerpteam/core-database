SELECT
PERSON_ID,
HOME_CENTER_ID,
replace(HOME_CENTER_PERSON_ID, ',','') AS HOME_CENTER_PERSON_ID,
DUPLICATE_OF_PERSON_ID,
TITLE,
replace(replace(replace(replace(replace(FULL_NAME, CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '')  AS FULL_NAME,
replace(replace(replace(replace(replace(FIRSTNAME, CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '')  AS FIRSTNAME,
replace(replace(replace(replace(replace(LASTNAME,  CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '')   AS LASTNAME,
COUNTRY_ID,
POSTAL_CODE,
CITY,
DATE_OF_BIRTH,
GENDER,
PERSON_TYPE,
PERSON_STATUS,
CREATION_DATE,
PAYER_PERSON_ID,
COMPANY_ID,
COUNTY,
STATE,
CAN_EMAIL,
CAN_SMS,
CENTER_ID
FROM
    BI_PERSONS biview
WHERE
    (to_date('19700101', 'YYYYMMDD') 
+ ( 1 / 24 / 60 / 60 / 1000) 
* biview.ETS) BETWEEN $$FROMDATE$$ AND $$TODATE$$
	and biview.CENTER_ID in ($$scope$$)
WITH
    PARAMS AS materialized
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 90), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS cutDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS todaysDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    p.center,
    p.id,
    --pea_email.txtvalue                                           AS Email,
    '',
    CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS PersonStatus,
	p.FIRSTNAME,
    p.LASTNAME,
   	p.EXTERNAL_ID AS EXTERNAL_ID,
	REPLACE(center.NAME, ',','')			  	 AS CenterName,
	LONGTODATE(scl.ENTRY_START_TIME) AS DELETE_DATE
FROM
    persons p
JOIN PARAMS params ON params.CenterID = p.CENTER
/*LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p.center
AND pea_email.PERSONID = p.id
AND pea_email.NAME = '_eClub_Email'*/

LEFT JOIN CENTERS center ON
	p.CENTER = center.ID
LEFT JOIN STATE_CHANGE_LOG scl ON
	scl.CENTER = p.CENTER
	AND scl.ID = p.id
WHERE
    p.sex != 'C'
AND p.status IN(7, 8)
AND center.COUNTRY != 'FI'
AND p.PERSONTYPE NOT IN (8,9)
--AND pea_email.txtvalue IS NOT NULL
--AND scl.STATEID = 7
AND scl.ENTRY_TYPE = 1
AND scl.ENTRY_START_TIME > cutDate - (1000* 60 * 60 * 24 * 6)

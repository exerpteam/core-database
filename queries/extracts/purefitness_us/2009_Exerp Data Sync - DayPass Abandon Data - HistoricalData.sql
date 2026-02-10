-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS materialized
     (
         SELECT
             id   AS  center,
             CAST(datetolongC(TO_CHAR(to_date('01-01-2016 00:00', 'dd-MM-yyyy HH24:MI'), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS FROMDATE,
             CAST(datetolongC(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) TODATE,
             'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
     )	
SELECT DISTINCT
    cp.EXTERNAL_ID                       AS "EXTERNALID",
	s.CENTER || 'ss' || s.ID AS "SUBSCRIPTIONID",
    pr.CENTER || 'prod' || pr.id AS "PRODUCTID",
	TO_CHAR(longtodate(s.CREATION_TIME) , 'YYYY-MM-DD') AS "MEMBERSIGNUPDATE",
    to_char(s.START_DATE, 'YYYY-MM-DD')  AS "STARTDATE",
    to_char(s.END_DATE, 'YYYY-MM-DD')    AS "ENDDATE",   
	s.SUBSCRIPTION_PRICE AS "PRICE",
    CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "STATE",
    CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS "SUBSTATE",
	TO_CHAR(longtodatetz(s.LAST_MODIFIED,params.TZFORMAT),params.DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
FROM
    PERSONS P   
JOIN
    params    
ON
    params.center = p.center	
JOIN
    PERSONS cp	
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.ID	    
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND P.PERSONTYPE != 2	
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    AND pr.GLOBALID IN ('DAY_PASS_30_DAY',
                        'DAY_PASS_3_DAY',
                        'DAY_PASS_1_DAY',
                        'DAY_PASS_7_DAY')
WHERE
    p.CENTER in ($$scope$$)
    AND s.creation_time >= params.FromDate
    AND s.creation_time < params.ToDate
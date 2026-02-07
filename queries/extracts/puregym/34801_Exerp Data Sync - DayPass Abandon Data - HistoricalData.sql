WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(to_char(to_date('01-01-2016 00:00', 'dd-MM-yyyy HH24:MI'), 'YYYY-MM-dd HH24:MI'),  'Europe/London')   AS FromDate,
            datetolongTZ(to_char(sysdate, 'YYYY-MM-dd HH24:MI'),  'Europe/London')                                             AS ToDate
        FROM
            dual
    )
SELECT DISTINCT
    cp.EXTERNAL_ID                       AS "EXTERNALID",
	s.CENTER || 'ss' || s.ID AS "SUBSCRIPTIONID",
    pr.CENTER || 'prod' || pr.id AS "PRODUCTID",
	TO_CHAR(longtodate(s.CREATION_TIME) , 'YYYY-MM-DD') AS "MEMBERSIGNUPDATE",
    to_char(s.START_DATE, 'YYYY-MM-DD')  AS "STARTDATE",
    to_char(s.END_DATE, 'YYYY-MM-DD')    AS "ENDDATE",   
	s.SUBSCRIPTION_PRICE AS "PRICE",
	DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS "STATE",
	DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS "SUBSTATE", 
    TO_CHAR(longtodatetz(s.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE"
FROM
    PERSONS P   
CROSS JOIN
    params    
JOIN
    PUREGYM.PERSONS cp	
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.ID	    
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND P.PERSONTYPE != 2	
JOIN
    PUREGYM.PRODUCTS pr
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
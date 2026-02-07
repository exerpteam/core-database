WITH
    any_club_in_scope AS
    (
        SELECT
            id,
            rownum
        FROM
            (
                SELECT
                    id,
                    ROW_NUMBER() OVER() AS rownum
                FROM
                    centers
                WHERE
                    id IN ($$scope$$)) rn
        WHERE
            rownum = 1
    )
     , params AS materialized
     (
         SELECT
            
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP)-INTERVAL '5 days', 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP+ INTERVAL '1 days'), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
         FROM any_club_in_scope
     )
 SELECT DISTINCT
     cp.EXTERNAL_ID                       AS "EXTERNALID",
         s.CENTER || 'ss' || s.ID AS "SUBSCRIPTIONID",
     pr.CENTER || 'prod' || pr.id AS "PRODUCTID",
         TO_CHAR(longtodate(s.CREATION_TIME) , 'YYYY-MM-DD') AS "MEMBERSIGNUPDATE",
     to_char(s.START_DATE, 'YYYY-MM-DD')  AS "STARTDATE",
     to_char(s.END_DATE, 'YYYY-MM-DD')    AS "ENDDATE",
            round(s.SUBSCRIPTION_PRICE,2) AS "PRICE",
         CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "STATE",
         CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS "SUBSTATE",
     TO_CHAR(longtodatetz(s.LAST_MODIFIED,'Europe/Zurich'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE"
 FROM
     PERSONS P
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
     --AND s.STATE = 8
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
     AND pr.GLOBALID IN ('DAY_PASS_30_DAY',
                         'DAY_PASS_3_DAY',
                         'DAY_PASS_1_DAY',
                         'ONE_DAY_PASS',
                         'DAY_PASS_7_DAY')
 CROSS JOIN params
 WHERE
     p.CENTER in ($$scope$$)
     AND s.LAST_MODIFIED >= PARAMS.FROMDATE
     AND s.LAST_MODIFIED < PARAMS.TODATE

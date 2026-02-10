-- The extract is extracted from Exerp on 2026-02-08
-- ST-6807
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR((TRUNC(exerpsysdate()) - INTERVAL '35' day) , 'YYYY-MM-dd HH24:MI'), 'Europe/Stockholm') AS DAYS_AGO_35,
            datetolongTZ(TO_CHAR((TRUNC(exerpsysdate()) - INTERVAL '34' day) , 'YYYY-MM-dd HH24:MI'), 'Europe/Stockholm') AS DAYS_AGO_34
        FROM  dual
    )  
SELECT
  p.center as CENTER,
  p.id as ID,
  p.center || 'p' ||p.id AS PERSONKEY,
  p.center||'p'||p.id as memberid,
  email.TXTVALUE AS "EMAIL",
  DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS "SUBSCRIPTION_STATE",
  DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9, 'CHILD', 10, 'EXTERNAL_STAFF','UNKNOWN') AS "PERSON_TYPE",
  CASE WHEN sessions.pt > 0
    THEN 'TRUE'
    ELSE 'FALSE'
  END AS  "PERSONAL_TRAINING",
  CASE WHEN sessions.groupex > 0
    THEN 'TRUE'
    ELSE 'FALSE'
  END AS "GROUP_TRAINING",
  c.COUNTRY  AS "COUNTRY",
  UPPER(c.SHORTNAME)  AS "CENTER_NAME"
FROM
  PARAMS
CROSS JOIN  
  PERSONS p
JOIN
  CENTERS c
ON
  p.CENTER = c.ID 
  AND c.COUNTRY = 'SE'
JOIN
(
SELECT
    t1.*
FROM
    PARAMS,
    (
        SELECT
            x.PersonCenter,
            x.PersonId,
            x.SubscriptionCenter,
            x.SubscriptionId,
            x.SubCreationTime,
            x.SubStartDate AS BOOK_S,
            ROUND((x.SubStartDate - lag(x.END_DATE) over (partition BY x.PersonCenter,x.PersonId ORDER BY  x.SubStartDate ASC))/(1000*60*60*24),2) AS DIST_TO_PREV
        FROM
            (
                SELECT
                    p.TRANSFERS_CURRENT_PRS_CENTER AS PersonCenter,
                    p.TRANSFERS_CURRENT_PRS_ID     AS PersonId,
                    s.ID                           AS SubscriptionId,
                    s.CENTER                       AS SubscriptionCenter,
                    s.CREATION_TIME                AS SubCreationTime,
                    MAX(scl1.BOOK_END_TIME)        AS END_DATE,
                    MIN(scl1.BOOK_START_TIME)      AS SubStartDate
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    PERSONS p
                ON
                    p.CENTER = s.OWNER_CENTER
                    AND p.ID = s.OWNER_ID
                JOIN
                    PERSONS cp
                ON
                    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
                JOIN
                    STATE_CHANGE_LOG scl1
                ON
                    scl1.center = s.center
                    AND scl1.id = s.id
                    AND scl1.ENTRY_TYPE = 2
                    AND scl1.STATEID = 2
                JOIN
                    STATE_CHANGE_LOG st
                ON
                    p.CENTER = st.CENTER
                    AND p.ID = st.ID
                    AND st.ENTRY_TYPE = 1
                    AND st.STATEID = 1
                WHERE
                    cp.CENTER in (:centers)
                GROUP BY
                    p.TRANSFERS_CURRENT_PRS_CENTER ,
                    p.TRANSFERS_CURRENT_PRS_ID ,
                    s.CENTER,
                    s.ID,
                    s.CREATION_TIME ) x ) t1
WHERE
    (t1.DIST_TO_PREV IS NULL  OR  t1.DIST_TO_PREV > 30)
    AND t1.BOOK_S >= PARAMS.DAYS_AGO_35
    AND t1.BOOK_S < PARAMS.DAYS_AGO_34
) t2
ON
    t2.PersonCenter = p.Center
    AND t2.PersonID = p.Id
JOIN
   SUBSCRIPTIONS s
ON
   s.CENTER = t2.SubscriptionCenter
   AND s.ID = t2.SubscriptionId
   AND s.STATE <> 3
LEFT JOIN
  PERSON_EXT_ATTRS email
ON
  email.PERSONCENTER = p.CENTER
  AND email.PERSONID = p.ID
  AND email.NAME = '_eClub_Email'
LEFT JOIN
(
SELECT 
   te.PARTICIPANT_CENTER,
   te.PARTICIPANT_ID,
   SUM(te.pt) AS PT,
   SUM(te.total)-SUM(te.pt) AS GROUPEX
FROM
(
SELECT 
   par.PARTICIPANT_CENTER, 
   par.PARTICIPANT_ID, 
   case when (ag.id = 2203 OR ag.top_node_id = 2203)
     THEN 1
     ELSE 0
   END AS pt,
   1 total
FROM
   PARTICIPATIONS par
JOIN 
   BOOKINGS b
ON
   b.CENTER = par.BOOKING_CENTER
   AND b.ID = par.BOOKING_ID
JOIN
   ACTIVITY a
ON 
   a.ID = b.ACTIVITY
JOIN
   ACTIVITY_GROUP ag
ON
   a.ACTIVITY_GROUP_ID = ag.ID 
JOIN
   CENTERS c
ON
   par.CENTER = c.ID 
   AND c.COUNTRY = 'SE'
WHERE 
   par.STATE <> 'CANCELLED'
) te
GROUP BY 
   te.PARTICIPANT_CENTER, te.PARTICIPANT_ID
) 
  sessions 
ON
  sessions.PARTICIPANT_CENTER = p.CENTER
  AND sessions.PARTICIPANT_ID = p.ID
WHERE
  p.STATUS NOT IN (2,4,5,7,8)
  AND p.PERSONTYPE NOT IN (2)
 

-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR((TRUNC(exerpsysdate()) - INTERVAL '35' DAY) , 'YYYY-MM-dd HH24:MI'),
            'Europe/Stockholm') AS DAYS_AGO_35,
            datetolongTZ(TO_CHAR((TRUNC(exerpsysdate()) - INTERVAL '34' DAY) , 'YYYY-MM-dd HH24:MI'),
            'Europe/Stockholm') AS DAYS_AGO_34,
            datetolongTZ(TO_CHAR((TRUNC(exerpsysdate()) - INTERVAL '65' DAY) , 'YYYY-MM-dd HH24:MI'),
            'Europe/Stockholm')                AS DAYS_AGO_65,
            TRUNC(exerpsysdate()) - INTERVAL '35' DAY AS DAYS_AGO_35_date,
            TRUNC(exerpsysdate()) - INTERVAL '34' DAY AS DAYS_AGO_34_date
        FROM
            dual
    )
SELECT
    p.center                                                                AS CENTER,
    p.id                                                                        AS ID,
    p.center || 'p' ||p.id                                                             AS PERSONKEY,
    p.center||'p'||p.id                                                                 AS MEMBERID,
    email.TXTVALUE                                                                       AS "EMAIL",
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS     "SUBSCRIPTION_STATE",
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,
    'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9, 'CHILD', 10, 'EXTERNAL_STAFF',
    'UNKNOWN') AS "PERSON_TYPE",
    CASE
        WHEN sess.pt > 0
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "PERSONAL_TRAINING",
    CASE
        WHEN sess.groupex > 0
        THEN 'TRUE'
        ELSE 'FALSE'
    END                AS "GROUP_TRAINING",
    c.COUNTRY          AS "COUNTRY",
    UPPER(c.SHORTNAME) AS "CENTER_NAME"
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
    center, id, LAST_INACTIVE, ENTRY_END_TIME
FROM
    (
        SELECT
            cp.EXTERNAL_ID,
            P.CENTER,
            P.ID,
            ST.STATEID AS state_from,
            ST.ENTRY_END_TIME,
            lag(st.stateid) over (partition BY cp.center,cp.id ORDER BY st.ENTRY_START_TIME DESC)  AS state_to,
            MAX(
                CASE
                    WHEN ST.STATEID = 2
                    THEN ENTRY_START_TIME
                    ELSE 0
                END) over (partition BY cp.center,cp.id ORDER BY st.ENTRY_START_TIME DESC) AS  LAST_INACTIVE,
            rank() over (partition BY cp.center,cp.id ORDER BY st.ENTRY_START_TIME DESC) AS rnk
        FROM
            params,
            PERSONS p
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
        AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
        JOIN
            STATE_CHANGE_LOG st
        ON
            p.CENTER = st.CENTER
        AND p.ID = st.ID
        AND st.ENTRY_TYPE = 1
        WHERE
            st.ENTRY_START_TIME < params.DAYS_AGO_34
          --  AND st.ENTRY_START_TIME >= params.DAYS_AGO_35
            AND st.STATEID NOT IN (3)
            AND cp.center in (:center)
    --        AND  (cp.center,cp.id) IN ((53,46434))
 
        ORDER BY
            st.entry_start_time)
WHERE
    (
        STATE_FROM,state_to) IN ((0,1), -- lead to active
                                 (2,1), -- inactive to active
                                 (6,1), -- prospect to active
                                 (9,1)) -- contact to active)
   AND rnk = 2
) t1
ON 
    t1.center = p.center
    AND t1.id = p.id
    AND LAST_INACTIVE < params.DAYS_AGO_65 
    AND ENTRY_END_TIME < params.DAYS_AGO_34
    AND ENTRY_END_TIME >= params.DAYS_AGO_35
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = t1.Center
    AND s.OWNER_ID = t1.Id
    AND s.STATE IN (2,7)
    AND s.START_DATE >= params.DAYS_AGO_35_date
    AND s.START_DATE < params.DAYS_AGO_34_date
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
            SUM(te.pt)               AS PT,
            SUM(te.total)-SUM(te.pt) AS GROUPEX
        FROM
            (
                SELECT
                    par.PARTICIPANT_CENTER,
                    par.PARTICIPANT_ID,
                    CASE
                        WHEN (ag.id = 2203
                            OR  ag.top_node_id = 2203)
                        THEN 1
                        ELSE 0
                    END AS pt,
                    1      total
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
                    par.STATE <> 'CANCELLED') te
        GROUP BY
            te.PARTICIPANT_CENTER,
            te.PARTICIPANT_ID ) sess
ON
    sess.PARTICIPANT_CENTER = p.CENTER
AND sess.PARTICIPANT_ID = p.ID

WHERE
    p.STATUS NOT IN (2,4,5,7,8)
AND p.PERSONTYPE NOT IN (2)
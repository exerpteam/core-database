WITH
    params AS
    /*+ materialize */
    (
        SELECT
            datetolong( TO_CHAR(TRUNC(SYSDATE -1 -$$offset$$,'YYYY'),'YYYY-MM-DD') || ' 00:00')               AS fromtime,
            datetolong( TO_CHAR( TRUNC(add_months(SYSDATE -1 -$$offset$$,1),'MM') ,'YYYY-MM-DD') || ' 00:00') AS totime
        FROM
            dual
    )
SELECT DISTINCT
    emp.CENTERID,
    c.SHORTNAME AS CLUB,
    c.COUNTRY,
    emp.MC_FIRSTNAME || ' ' || emp.MC_LASTNAME AS MC,
    month_list.MON                             AS "Month",
    NVL(LEAD,0)                                AS LEAD,
    NVL(LEAD_OVERDUE,0)                        AS LEAD_OVERDUE,
    NVL(HOT,0)                                 AS HOT,
    NVL(HOT_OVERDUE,0)                         AS HOT_OVERDUE,
    NVL(WARM,0)                                AS WARM,
    NVL(WARM_OVERDUE,0)                        AS WARM_OVERDUE,
    NVL(COLD,0)                                AS COLD,
    NVL(COLD_OVERDUE,0)                        AS COLD_OVERDUE,
    NVL(FUTURE,0)                              AS FUTURE,
    NVL(FUTURE_OVERDUE,0)                      AS FUTURE_OVERDUE,
    NVL(NEW_LEADS,0)                           AS NEW_LEADS,
    NVL(CALLS,0)                               AS CALLS,
    NVL(BOOKED,0)                              AS BOOKED,
    NVL(BEBACK,0)                              AS BEBACK,
    NVL(SHOWUPS,0)                             AS SHOWUPS,
    NVL(WALKINS,0)                             AS WALKINS,
    NVL(SALES,0)                               AS SALES,
    NVL(Suspect_Sale,0)                        AS Suspect_Sale,
    NVL(WALKIN_SALE,0)                         AS WALKIN_SALE,
    NVL(Booked_SALE,0)                         AS Booked_SALE,
    NVL(Beback_SALE,0)                         AS Beback_SALE,
    NVL(NO_TASK,0)                             AS NO_TASK_SALE,
    NVL(ENDS,0)                                AS ENDS,
    NVL( OTHERS,0)                             AS OTHERS,
    NVL(AVG_DAYS_TO_END,0)                     AS AVG_DAYS_TO_END,
    NVL(AVG_DAYS_TO_SALE,0)                    AS AVG_DAYS_TO_SALE,
    NVL(AVG_BOOK_TO_SALE,0)                    AS AVG_BOOK_TO_SALE,
    NVL(AVG_Days_To_Future,0)                  AS Days_To_Future,
    NVL(F_Bookings.Books5Days,0)               AS Next_5_days_Bookings,
    NVL(no_CRM_sale.num,0)                     AS No_CRM_SALE
FROM
    (
        SELECT DISTINCT
            *
        FROM
            (
                SELECT DISTINCT
                    t.CENTER      AS centerId,
                    emp.FIRSTNAME AS MC_FIRSTNAME,
                    emp.LASTNAME  AS MC_LASTNAME
                FROM
                    HP.PERSONS emp
                JOIN
                    HP.TASKS t
                ON
                    emp.center = t.ASIGNEE_CENTER
                    AND emp.id = t.ASIGNEE_ID
                WHERE
                    emp.PERSONTYPE = 2
                    AND t.center IN ($$scope$$)
                UNION ALL
                SELECT
                    s.center,
                    staff.FIRSTNAME,
                    staff.LASTNAME
                FROM
                    params,
                    HP.SUBSCRIPTIONS s
                JOIN
                    HP.EMPLOYEES emp
                ON
                    emp.CENTER = s.CREATOR_CENTER
                    AND emp.id = s.CREATOR_ID
                JOIN
                    HP.PERSONS staff
                ON
                    staff.CENTER = emp.PERSONCENTER
                    AND staff.id = emp.PERSONID
                WHERE
                    s.CREATION_TIME BETWEEN params.fromtime AND params.totime
                    AND (
                        s.START_DATE <=s.END_DATE
                        OR s.END_DATE IS NULL)
                    AND s.center IN ($$scope$$)
                UNION ALL
                SELECT DISTINCT
                    t.center AS centerId,
                    'Unassigned',
                    'Unassigned'
                FROM
                    HP.TASKS t
                WHERE
                    t.center IN ($$scope$$) )) emp
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    t.center                         AS centerId,
                    NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
                    CASE
                        WHEN (p.status = 0)
                        THEN 'LEAD'
                        WHEN (p.status = 6 )
                        THEN tg.EXTERNAL_ID
                        ELSE 'OTHER'
                    END ||
                    CASE
                        WHEN (t.status = 'OVERDUE')
                        THEN '_OVERDUE'
                        ELSE ''
                    END  AS Category,
                    t.id AS id
                FROM
                    HP.tasks t
                JOIN
                    HP.TASK_CATEGORIES tg
                ON
                    t.TASK_CATEGORY_ID = tg.id
                JOIN
                    HP.persons p
                ON
                    p.center = t.PERSON_CENTER
                    AND p.id = t.person_id
                LEFT JOIN
                    HP.persons emp
                ON
                    emp.center = t.ASIGNEE_CENTER
                    AND emp.id = t.ASIGNEE_ID
                WHERE
                    TYPE_ID = 200
                    AND t.center IN ($$scope$$)
                    AND
                    -- LEAD: 0 , PROSPECT: 6
                    p.STATUS IN (0,6)
                    AND t.STATUS NOT IN ('CLOSED',
                                         'DELETED') )
            -- PIVOT
            PIVOT (COUNT(id) FOR (category) IN ( 'LEAD'          AS LEAD ,
                                                'LEAD_OVERDUE'   AS LEAD_OVERDUE ,
                                                'HOT'            AS HOT ,
                                                'HOT_OVERDUE'    AS HOT_OVERDUE ,
                                                'WARM'           AS WARM ,
                                                'WARM_OVERDUE'   AS WARM_OVERDUE ,
                                                'COLD'           AS COLD ,
                                                'COLD_OVERDUE'   AS COLD_OVERDUE ,
                                                'FUTURE'         AS FUTURE ,
                                                'FUTURE_OVERDUE' AS FUTURE_OVERDUE ) )
        ORDER BY
            CENTERID,
            MC_FIRSTNAME,
            MC_LASTNAME ) taskcount
ON
    emp.MC_FIRSTNAME = taskcount.MC_FIRSTNAME
    AND emp.MC_LASTNAME = taskcount.MC_LASTNAME
    AND emp.centerId = taskcount.centerId
CROSS JOIN
    (
        SELECT
            TO_CHAR( add_months( start_date, level-1 ), 'MON' ) mon
        FROM
            (
                /*+ materialize */
                SELECT
                    TRUNC(add_months(SYSDATE -1 -$$offset$$,1),'YYYY') start_date,
                    TRUNC(SYSDATE -1 -$$offset$$ ,'MM')                end_date
                FROM
                    dual) CONNECT BY level <= (months_between( start_date, end_date ) -1) * -1) month_list
LEFT JOIN
    (
        SELECT
            t.CENTER                         AS CENTERID,
            NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
            NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
            COUNT(t.id)                      AS NEW_LEADS
        FROM
            params ,
            HP.tasks t
        LEFT JOIN
            HP.persons emp
        ON
            emp.center = t.ASIGNEE_CENTER
            AND emp.id = t.ASIGNEE_ID
        WHERE
            t.TYPE_ID = 200
            AND t.center IN ($$scope$$)
            AND t.CREATION_TIME BETWEEN params.fromtime AND params.totime
        GROUP BY
            t.center,
            emp.FIRSTNAME,
            emp.LASTNAME
        ORDER BY
            t.CENTER,
            emp.FIRSTNAME,
            emp.LASTNAME ) LEADCOUNT
ON
    emp.centerid = leadcount.centerid
    AND emp.MC_FIRSTNAME = leadcount.MC_FIRSTNAME
    AND emp.MC_LASTNAME = leadcount.MC_LASTNAME
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    t.center                                         AS CenterId,
                    TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                    NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                    /**ta.name                                              AS actionname,
                    ta.id                                                AS actionid,**/
                    CASE
                        WHEN ta.id IN (403)
                        THEN 'Booked'
                        WHEN ta.id IN( 407)
                        THEN 'ShowUp'
                        WHEN ta.id IN ( 402)
                            AND EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    HP.SUBSCRIPTIONS s
                                WHERE
                                    s.owner_center = t.PERSON_CENTER
                                    AND s.OWNER_ID = t.PERSON_ID
                                    AND ( s.START_DATE <=s.END_DATE
                                        OR s.END_DATE IS NULL)
                                    AND s.CREATION_TIME BETWEEN tl.ENTRY_TIME - 1000*60*60*24 AND tl.ENTRY_TIME + 1000*60*60*24
                                    AND tl.TASK_ACTION_ID = 402)
                        THEN 'Sale'
                        WHEN ta.id IN ( 402)
                            AND NOT EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    HP.SUBSCRIPTIONS s
                                WHERE
                                    s.owner_center = t.PERSON_CENTER
                                    AND s.OWNER_ID = t.PERSON_ID
                                    AND ( s.START_DATE <=s.END_DATE
                                        OR s.END_DATE IS NULL)
                                    AND s.CREATION_TIME BETWEEN tl.ENTRY_TIME - 1000*60*60*24 AND tl.ENTRY_TIME + 1000*60*60*24
                                    AND tl.TASK_ACTION_ID = 402)
                        THEN 'Suspect_Sale'
                        WHEN ta.id IN( 401,404,410)
                        THEN 'Call'
                        WHEN ta.id IN ( 409)
                        THEN 'End'
                        WHEN ta.id IN ( 600)
                        THEN 'Walkin'
                        WHEN ta.id IN ( 400)
                        THEN 'Beback'
                        ELSE 'Other'
                    END   AS "Action",
                    tl.ID AS logid
                FROM
                    params ,
                    HP.tasks t
                JOIN
                    HP.TASK_LOG tl
                ON
                    tl.TASK_ID = t.id
                JOIN
                    HP.TASK_ACTIONS ta
                ON
                    ta.ID = tl.TASK_ACTION_ID
                LEFT JOIN
                    HP.persons emp
                ON
                    emp.center = t.ASIGNEE_CENTER
                    AND emp.id = t.ASIGNEE_ID
                WHERE
                    t.TYPE_ID = 200
                    AND t.center IN ($$scope$$)
                    AND ta.ID IN (401,400,402,403,404,407,409,410,600)
                    AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime )
            --- PIVOT
            pivot (COUNT (logid) FOR "Action" IN ( 'Call'        AS Calls,
                                                  'Booked'       AS Booked,
                                                  'Beback'       AS Beback,
                                                  'ShowUp'       AS ShowUps ,
                                                  'Sale'         AS Sales ,
                                                  'Suspect_Sale' AS Suspect_Sale,
                                                  'Walkin'       AS Walkins,
                                                  'End'          AS Ends,
                                                  'Other'        AS OTHERS ))
        ORDER BY
            CENTERID,
            MC_FIRSTNAME,
            MC_LASTNAME ) ACTIONCOUNT
ON
    emp.centerid = ACTIONCOUNT.centerid
    AND emp.MC_FIRSTNAME = ACTIONCOUNT.MC_FIRSTNAME
    AND emp.MC_LASTNAME = ACTIONCOUNT.MC_LASTNAME
    AND ACTIONCOUNT.MON = month_list.mon
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    t.center                                         AS CenterId,
                    NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                    t.id                                             AS taskid,
                    TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                    CASE
                        WHEN counts.BEBACK > 0
                        THEN 'Beback Sale'
                        WHEN counts.WALKINS>0
                            AND counts.BEBACK = 0
                        THEN 'Walkin Sale'
                        WHEN counts.BOOKED>0
                            AND counts.WALKINS=0
                            AND counts.BEBACK = 0
                        THEN 'Booked Sale'
                        WHEN counts.BOOKED=0
                            AND counts.WALKINS=0
                            AND counts.BEBACK = 0
                        THEN 'No tasks'
                    END AS "SALES"
                FROM
                    params ,
                    HP.tasks t
                JOIN
                    HP.TASK_LOG tl
                ON
                    tl.TASK_ID = t.id
                JOIN
                    HP.TASK_ACTIONS ta
                ON
                    ta.ID = tl.TASK_ACTION_ID
                LEFT JOIN
                    (
                        SELECT
                            t.ID,
                            SUM(DECODE (ta.id,600,1,0)) AS WALKINS,
                            SUM(DECODE (ta.id,400,1,0)) AS BEBACK,
                            SUM(DECODE (ta.id,403,1,0)) AS BOOKED
                        FROM
                            params ,
                            HP.tasks t
                        JOIN
                            HP.TASK_LOG tl
                        ON
                            tl.TASK_ID = t.id
                        JOIN
                            HP.TASK_ACTIONS ta
                        ON
                            ta.ID = tl.TASK_ACTION_ID
                        WHERE
                            t.TYPE_ID = 200
                            AND ta.ID IN (400,403,600,402)
                            AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime
                            AND EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    HP.TASK_LOG tl2
                                JOIN
                                    HP.TASK_ACTIONS ta2
                                ON
                                    ta2.ID = tl2.TASK_ACTION_ID
                                WHERE
                                    tl2.TASK_ID = t.id
                                    AND ta2.ID = 402
                                    AND tl2.ENTRY_TIME BETWEEN params.fromtime AND params.totime)
                        GROUP BY
                            t.id) counts
                ON
                    counts.id = t.id
                LEFT JOIN
                    HP.persons emp
                ON
                    emp.center = t.ASIGNEE_CENTER
                    AND emp.id = t.ASIGNEE_ID
                WHERE
                    t.TYPE_ID = 200
                    AND ta.ID IN (400,401,402,403,404,407,409,410,600)
                    AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) pivot (COUNT ( DISTINCT taskid) FOR "SALES" IN ( 'Walkin Sale' AS WALKIN_SALE,
                                                                                                                                  'Booked Sale'  AS Booked_SALE,
                                                                                                                                  'Beback Sale'  AS Beback_SALE,
                                                                                                                                  'No tasks'     AS NO_TASK))) SALESCOUNT
ON
    emp.centerid = SALESCOUNT.centerid
    AND emp.MC_FIRSTNAME = SALESCOUNT.MC_FIRSTNAME
    AND emp.MC_LASTNAME = SALESCOUNT.MC_LASTNAME
    AND month_list.mon = SALESCOUNT.MON
LEFT JOIN
    (
        SELECT
            CENTERID,
            MC_FIRSTNAME,
            MC_LASTNAME,
            ROUND("End",2)        AS AVG_DAYS_TO_END,
            ROUND("Sale",2)       AS AVG_DAYS_TO_SALE,
            ROUND("BookToSale",2) AS AVG_BOOK_TO_SALE,
            ROUND("Future",2)     AS AVG_Days_To_Future,
            MON
        FROM
            (
                SELECT
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    "Action",
                    AVG("CreationToAction") AS "Time",
                    MON
                FROM
                    (
                        SELECT
                            t.center                                         AS CENTERID,
                            NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
                            NVL(ROUND((tl.ENTRY_TIME- t.CREATION_TIME)/(3600*24*1000) ,1),0) AS "CreationToAction",
                            CASE
                                WHEN ta.id IN ( 402)
                                THEN 'Sale'
                                WHEN ta.id IN ( 409)
                                THEN 'End'
                                ELSE 'Other'
                            END AS "Action"
                        FROM
                            params ,
                            HP.tasks t
                        JOIN
                            HP.TASK_LOG tl
                        ON
                            tl.TASK_ID = t.id
                        JOIN
                            HP.TASK_ACTIONS ta
                        ON
                            ta.ID = tl.TASK_ACTION_ID
                        LEFT JOIN
                            HP.persons emp
                        ON
                            emp.center = t.ASIGNEE_CENTER
                            AND emp.id = t.ASIGNEE_ID
                        WHERE
                            t.TYPE_ID = 200
                            AND t.center IN ($$scope$$)
                            AND ta.ID IN (402,409)
                            AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime )
                GROUP BY
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    "Action",
                    MON
                UNION
                SELECT
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    'BookToSale'        AS "Action",
                    AVG("BookToAction") AS "Time",
                    MON
                FROM
                    (
                        SELECT
                            t.center                                         AS CENTERID,
                            NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
                            CASE
                                WHEN ta.id IN ( 402)
                                THEN
                                    (
                                        SELECT
                                            ROUND((tl.ENTRY_TIME-MAX(tl2.ENTRY_TIME))/(3600*24*1000 ) ,1)
                                        FROM
                                            HP.TASK_LOG tl2
                                        WHERE
                                            tl2.TASK_ID = t.id
                                            AND tl2.task_action_id = 403 -- book
                                            -- 407 showup
                                    )
                                ELSE 0
                            END AS "BookToAction"
                        FROM
                            params ,
                            HP.tasks t
                        JOIN
                            HP.TASK_LOG tl
                        ON
                            tl.TASK_ID = t.id
                        JOIN
                            HP.TASK_ACTIONS ta
                        ON
                            ta.ID = tl.TASK_ACTION_ID
                        LEFT JOIN
                            HP.persons emp
                        ON
                            emp.center = t.ASIGNEE_CENTER
                            AND emp.id = t.ASIGNEE_ID
                        WHERE
                            t.TYPE_ID = 200
                            AND t.center IN ($$scope$$)
                            AND ta.ID IN (402)
                            AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime )
                GROUP BY
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    MON
                UNION
                SELECT
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    'Future'      AS "Action",
                    AVG("Future") AS "Time",
                    MON
                FROM
                    (
                        SELECT
                            t.center                                         AS CENTERID,
                            NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
                            NVL(ROUND((tl.ENTRY_TIME- t.CREATION_TIME)/(3600*24*1000) ,1),0) AS "Future",
                            'Future'                                                         AS "Action"
                        FROM
                            params ,
                            HP.tasks t
                        JOIN
                            HP.TASK_LOG tl
                        ON
                            tl.TASK_ID = t.id
                        JOIN
                            HP.TASK_LOG_DETAILS tld
                        ON
                            tld.TASK_LOG_ID = tl.id
                        LEFT JOIN
                            HP.persons emp
                        ON
                            emp.center = t.ASIGNEE_CENTER
                            AND emp.id = t.ASIGNEE_ID
                        WHERE
                            t.TYPE_ID = 200
                            AND t.center IN ($$scope$$)
                            AND tld.NAME = '_eClub_TASK_CATEGORY'
                            AND tld.VALUE = 'FUTURE'
                            AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime)
                GROUP BY
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    MON) pivot (SUM ("Time") FOR "Action" IN ('End'        AS "End",
                                                              'Sale'       AS "Sale",
                                                              'BookToSale' AS "BookToSale",
                                                              'Future'     AS "Future") )
        ORDER BY
            CENTERID,
            MC_FIRSTNAME,
            MC_LASTNAME ) PERFORMANCE
ON
    emp.centerid = PERFORMANCE.centerid
    AND emp.MC_FIRSTNAME = PERFORMANCE.MC_FIRSTNAME
    AND emp.MC_LASTNAME = PERFORMANCE.MC_LASTNAME
    AND month_list.mon=PERFORMANCE.MON
LEFT JOIN
    (
        SELECT
            p.FIRSTNAME AS MC_FIRSTNAME,
            p.LASTNAME  AS MC_LASTNAME,
            bo.CENTER   AS centerid,
            COUNT(*)    AS Books5Days
        FROM
            HP.BOOKINGS bo
        CROSS JOIN
            params
        JOIN
            HP.PERSONS p
        ON
            p.CENTER = bo.CREATOR_CENTER
            AND p.id = bo.CREATOR_ID
        JOIN
            HP.ACTIVITY ac
        ON
            ac.id = bo.ACTIVITY
        JOIN
            HP.ACTIVITY_GROUP ag
        ON
            ag.id = ac.ACTIVITY_GROUP_ID
        WHERE
            bo.STARTTIME BETWEEN params.totime AND params.totime + 1000*60*60*24*5
            AND bo.STATE = 'ACTIVE'
            AND ag.id = 1803
        GROUP BY
            p.FIRSTNAME,
            p.LASTNAME,
            bo.CENTER) F_Bookings
ON
    emp.centerid = F_Bookings.centerid
    AND emp.MC_FIRSTNAME = F_Bookings.MC_FIRSTNAME
    AND emp.MC_LASTNAME = F_Bookings.MC_LASTNAME
LEFT JOIN
    (--Sales done by staff during the period, but did not go through the CRM
        SELECT
            s.CENTER,
            staff.FIRSTNAME,
            staff.LASTNAME,
            TO_CHAR(longtodate(s.CREATION_TIME),'MON')    MON,
            COUNT(DISTINCT s.OWNER_CENTER||'p'||s.OWNER_ID)    AS num
        FROM
            params,
            HP.PERSONS p
        JOIN
            HP.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.id
            AND (
                s.START_DATE <=s.END_DATE
                OR s.END_DATE IS NULL)
        JOIN
            HP.EMPLOYEES emp
        ON
            emp.CENTER = s.CREATOR_CENTER
            AND emp.id = s.CREATOR_ID
        JOIN
            HP.PERSONS staff
        ON
            staff.CENTER = emp.PERSONCENTER
            AND staff.id = emp.PERSONID
        JOIN
            HP.SUBSCRIPTIONTYPES st
        ON
            st.center = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            s.CREATION_TIME BETWEEN params.fromtime AND params.totime
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.TASKS t
                LEFT JOIN
                    HP.TASK_LOG tl
                ON
                    tl.TASK_ID = t.id
                    AND tl.TASK_ACTION_ID = 402
                WHERE
                    t.PERSON_CENTER = p.CENTER
                    AND t.PERSON_ID = p.id
                    AND tl.ENTRY_TIME BETWEEN s.CREATION_TIME - 1000*60*60*24 AND s.CREATION_TIME + 1000*60*60*24)
            AND s.center IN ($$scope$$)
            AND st.IS_ADDON_SUBSCRIPTION = 0
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    ppg.product_center = s.SUBSCRIPTIONTYPE_CENTER
                    AND ppg.product_id = s.SUBSCRIPTIONTYPE_ID
                    AND ppg.PRODUCT_GROUP_ID = 1201 )
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.SUBSCRIPTIONS s2
                JOIN
                    HP.PERSONS p2
                ON
                    p2.CENTER = s2.OWNER_CENTER
                    AND p2.id = s2.OWNER_ID
                WHERE
                    p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                    AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
                    AND (
                        s2.START_DATE <=s2.END_DATE
                        OR s2.END_DATE IS NULL)
                    AND s2.CREATION_TIME< s.CREATION_TIME
                    AND (
                        s2.END_DATE > add_months(s.START_DATE,-3)
                        OR s2.END_DATE IS NULL))
        GROUP BY
            s.center,
            staff.FIRSTNAME,
            staff.LASTNAME,
            TO_CHAR(longtodate(s.CREATION_TIME),'MON')) no_CRM_sale
ON
    no_CRM_sale.FIRSTNAME = emp.MC_FIRSTNAME
    AND no_CRM_sale.LASTNAME = emp.MC_LASTNAME
    AND no_CRM_sale.mon = month_list.MON
    AND no_CRM_sale.center = emp.CENTERID
JOIN
    HP.centers c
ON
    c.id = emp.CENTERID
WHERE
    taskcount.MC_FIRSTNAME IS NOT NULL
    OR ACTIONCOUNT.MC_FIRSTNAME IS NOT NULL
    OR PERFORMANCE.MC_FIRSTNAME IS NOT NULL
    OR no_CRM_sale.FIRSTNAME IS NOT NULL
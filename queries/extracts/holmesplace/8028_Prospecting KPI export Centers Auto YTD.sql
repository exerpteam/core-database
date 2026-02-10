-- The extract is extracted from Exerp on 2026-02-08
--  
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
SELECT
    CENTERID,
    CLUB,
    COUNTRY,
    "Month",
    SUM(LEAD)                 AS LEAD,
    SUM( LEAD_OVERDUE)        AS LEAD_OVERDUE,
    SUM( HOT)                 AS HOT,
    SUM( HOT_OVERDUE)         AS HOT_OVERDUE,
    SUM( WARM)                AS WARM,
    SUM( WARM_OVERDUE)        AS WARM_OVERDUE,
    SUM( COLD)                AS COLD,
    SUM( COLD_OVERDUE)        AS COLD_OVERDUE,
    SUM( FUTURE)              AS FUTURE,
    SUM( FUTURE_OVERDUE)      AS FUTURE_OVERDUE,
    SUM( NEW_LEADS)           AS NEW_LEADS,
    SUM( CALLS)               AS CALLS,
    SUM( BOOKED)              AS BOOKED,
    SUM( BEBACK)              AS BEBACK,
    SUM( SHOWUPS)             AS SHOWUPS,
    SUM( WALKINS)             AS WALKINS,
    SUM( SALES)               AS SALES,
    SUM( WALKIN_SALE)         AS WALKIN_SALE,
    SUM( Booked_SALE)         AS Booked_SALE,
    SUM( Beback_SALE)         AS Beback_SALE,
    SUM( NO_TASK_SALE)        AS NO_TASK_SALE,
    SUM( ENDS)                AS ENDS,
    SUM( OTHERS)              AS OTHERS,
    AVG(AVG_DAYS_TO_END)      AS AVG_DAYS_TO_END,
    AVG( AVG_DAYS_TO_SALE)    AS AVG_DAYS_TO_SALE,
    AVG( AVG_BOOK_TO_SALE)    AS AVG_BOOK_TO_SALE,
    AVG( Days_To_Future)      AS Days_To_Future,
    SUM(Next_5_days_Bookings) AS Next_5_days_Bookings,
    SUM( No_CRM_SALE)         AS No_CRM_SALE
FROM
    (
        SELECT DISTINCT
            taskcount.CENTERID                                                                          AS CENTERID,
            DECODE(taskcount.MC_FIRSTNAME,'Unassigned',taskcount.CLUB||' - Unassigned', taskcount.CLUB) AS CLUB,
            c.COUNTRY                                                                                   AS COUNTRY,
            taskcount.MC_FIRSTNAME || ' ' || taskcount.MC_LASTNAME                                      AS MC,
            month_list.MON                                                                              AS "Month",
            LEAD,
            LEAD_OVERDUE,
            HOT,
            HOT_OVERDUE,
            WARM,
            WARM_OVERDUE,
            COLD,
            COLD_OVERDUE,
            FUTURE,
            FUTURE_OVERDUE,
            NVL(NEW_LEADS,0)             AS NEW_LEADS,
            NVL(CALLS,0)                 AS CALLS,
            NVL(BOOKED,0)                AS BOOKED,
            NVL(BEBACK,0)                AS BEBACK,
            NVL(SHOWUPS,0)               AS SHOWUPS,
            NVL(WALKINS,0)               AS WALKINS,
            NVL(SALES,0)                 AS SALES,
            NVL(WALKIN_SALE,0)           AS WALKIN_SALE,
            NVL(Booked_SALE,0)           AS Booked_SALE,
            NVL(Beback_SALE,0)           AS Beback_SALE,
            NVL(NO_TASK,0)               AS NO_TASK_SALE,
            NVL(ENDS,0)                  AS ENDS,
            NVL( OTHERS,0)               AS OTHERS,
            NVL(AVG_DAYS_TO_END,0)       AS AVG_DAYS_TO_END,
            NVL(AVG_DAYS_TO_SALE,0)      AS AVG_DAYS_TO_SALE,
            NVL(AVG_BOOK_TO_SALE,0)      AS AVG_BOOK_TO_SALE,
            NVL(AVG_Days_To_Future,0)    AS Days_To_Future,
            NVL(F_Bookings.Books5Days,0) AS Next_5_days_Bookings,
            NVL(no_CRM_sale.num,0)       AS No_CRM_SALE
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            t.center                         AS centerId,
                            c.SHORTNAME                      AS Club,
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
                            HP.centers c
                        ON
                            t.center = c.id
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
                    club,
                    MC_FIRSTNAME,
                    MC_LASTNAME ) taskcount
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
                    c.id                             AS CENTERID,
                    c.shortname                      AS Club,
                    NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
                    COUNT(t.id)                      AS NEW_LEADS
                FROM
                    params ,
                    HP.tasks t
                JOIN
                    HP.centers c
                ON
                    c.id = t.CENTER
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
                    c.id,
                    c.shortname,
                    emp.FIRSTNAME,
                    emp.LASTNAME
                ORDER BY
                    c.id,
                    c.shortname,
                    emp.FIRSTNAME,
                    emp.LASTNAME ) LEADCOUNT
        ON
            taskcount.centerid = leadcount.centerid
            AND taskcount.club = leadcount.Club
            AND taskcount.MC_FIRSTNAME = leadcount.MC_FIRSTNAME
            AND taskcount.MC_LASTNAME = leadcount.MC_LASTNAME
        LEFT JOIN
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            t.center                                         AS CenterId,
                            c.SHORTNAME                                      AS Club,
                            NVL( emp.FIRSTNAME,'Unassigned')                 AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')                  AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
                            CASE
                                WHEN ta.id IN (403)
                                THEN 'Booked'
                                WHEN ta.id IN( 407)
                                THEN 'ShowUp'
                                WHEN ta.id IN ( 402)
                                THEN 'Sale'
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
                            HP.centers c
                        ON
                            c.id = t.CENTER
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
                    pivot (COUNT (logid) FOR "Action" IN ( 'Call'  AS Calls,
                                                          'Booked' AS Booked,
                                                          'Beback' AS Beback,
                                                          'ShowUp' AS ShowUps ,
                                                          'Sale'   AS Sales ,
                                                          'Walkin' AS Walkins,
                                                          'End'    AS Ends,
                                                          'Other'  AS OTHERS ))
                ORDER BY
                    CENTERID,
                    club,
                    MC_FIRSTNAME,
                    MC_LASTNAME ) ACTIONCOUNT
        ON
            taskcount.centerid = ACTIONCOUNT.centerid
            AND taskcount.club = ACTIONCOUNT.Club
            AND taskcount.MC_FIRSTNAME = ACTIONCOUNT.MC_FIRSTNAME
            AND taskcount.MC_LASTNAME = ACTIONCOUNT.MC_LASTNAME
            AND ACTIONCOUNT.MON = month_list.mon
        LEFT JOIN
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            t.center                                         AS CenterId,
                            c.SHORTNAME                                      AS Club,
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
                            HP.centers c
                        ON
                            c.id = t.CENTER
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
            taskcount.centerid = SALESCOUNT.centerid
            AND taskcount.club = SALESCOUNT.Club
            AND taskcount.MC_FIRSTNAME = SALESCOUNT.MC_FIRSTNAME
            AND taskcount.MC_LASTNAME = SALESCOUNT.MC_LASTNAME
            AND month_list.mon = SALESCOUNT.MON
        LEFT JOIN
            (
                SELECT
                    CENTERID,
                    CLUB AS Club,
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
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            "Action",
                            AVG("CreationToAction") AS "Time",
                            MON
                        FROM
                            (
                                SELECT
                                    t.center                                         AS CENTERID,
                                    c.SHORTNAME                                      AS Club,
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
                                    HP.centers c
                                ON
                                    c.id = t.CENTER
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
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            "Action",
                            MON
                        UNION
                        SELECT
                            CENTERID,
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            'BookToSale'        AS "Action",
                            AVG("BookToAction") AS "Time",
                            MON
                        FROM
                            (
                                SELECT
                                    t.center                                         AS CENTERID,
                                    c.SHORTNAME                                      AS Club,
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
                                    HP.centers c
                                ON
                                    c.id = t.CENTER
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
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            MON
                        UNION
                        SELECT
                            CENTERID,
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            'Future'      AS "Action",
                            AVG("Future") AS "Time",
                            MON
                        FROM
                            (
                                SELECT
                                    t.center                                         AS CENTERID,
                                    c.SHORTNAME                                      AS Club,
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
                                    HP.centers c
                                ON
                                    c.id = t.CENTER
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
                            CLUB,
                            MC_FIRSTNAME,
                            MC_LASTNAME,
                            MON) pivot (SUM ("Time") FOR "Action" IN ('End'        AS "End",
                                                                      'Sale'       AS "Sale",
                                                                      'BookToSale' AS "BookToSale",
                                                                      'Future'     AS "Future") )
                ORDER BY
                    CENTERID,
                    club,
                    MC_FIRSTNAME,
                    MC_LASTNAME ) PERFORMANCE
        ON
            taskcount.centerid = PERFORMANCE.centerid
            AND taskcount.club = PERFORMANCE.Club
            AND taskcount.MC_FIRSTNAME = PERFORMANCE.MC_FIRSTNAME
            AND taskcount.MC_LASTNAME = PERFORMANCE.MC_LASTNAME
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
            taskcount.centerid = F_Bookings.centerid
            AND taskcount.MC_FIRSTNAME = F_Bookings.MC_FIRSTNAME
            AND taskcount.MC_LASTNAME = F_Bookings.MC_LASTNAME
        LEFT JOIN
            (
                SELECT
                    s.CENTER,
                    staff.FIRSTNAME,
                    staff.LASTNAME,
                    TO_CHAR(longtodate(s.CREATION_TIME),'MON')    MON,
                    COUNT(*)                                           AS num
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
                LEFT JOIN
                    HP.TASKS t
                ON
                    t.PERSON_CENTER = p.CENTER
                    AND t.PERSON_ID = p.id
                LEFT JOIN
                    HP.TASK_LOG tl
                ON
                    tl.TASK_ID = t.id
                    AND tl.TASK_ACTION_ID = 402
                    AND tl.ENTRY_TIME BETWEEN s.CREATION_TIME - 1000*60*60*12 AND s.CREATION_TIME + 1000*60*60*12
                WHERE
                    s.CREATION_TIME BETWEEN params.fromtime AND params.totime
                    AND tl.id IS NULL
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
                        JOIN
                            HP.STATE_CHANGE_LOG scl
                        ON
                            scl.CENTER = s2.CENTER
                            AND scl.id = s2.ID
                            AND scl.ENTRY_TYPE = 2
                            AND scl.STATEID IN (2,4)
                        WHERE
                            p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                            AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
                            AND (
                                s2.START_DATE <=s2.END_DATE
                                OR s2.END_DATE IS NULL)
                            AND (
                                scl.BOOK_END_TIME > s.CREATION_TIME -1000*60*60*24
                                OR scl.BOOK_END_TIME IS NULL)
                            AND scl.BOOK_START_TIME < s.CREATION_TIME -1000*60*60*24)
                GROUP BY
                    s.center,
                    staff.FIRSTNAME,
                    staff.LASTNAME,
                    TO_CHAR(longtodate(s.CREATION_TIME),'MON')) no_CRM_sale
        ON
            no_CRM_sale.FIRSTNAME = taskcount.MC_FIRSTNAME
            AND no_CRM_sale.LASTNAME = taskcount.MC_LASTNAME
            AND no_CRM_sale.mon = PERFORMANCE.MON
            AND no_CRM_sale.center = taskcount.CENTERID
        LEFT JOIN
            HP.centers c
        ON
            c.id = taskcount.CENTERID)
GROUP BY
    CENTERID,
    CLUB,
    COUNTRY,
    "Month"
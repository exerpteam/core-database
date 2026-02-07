WITH
    params AS
    (
        SELECT
            datetolong( TO_CHAR(TRUNC(SYSDATE,'MM'),'YYYY-MM-DD') || ' 00:00') AS fromtime,
            datetolong( TO_CHAR( SYSDATE ,'YYYY-MM-DD') || ' 00:00')           AS totime
        FROM
            dual
    )
SELECT
    taskcount.CENTERID,
    taskcount.CLUB,
    taskcount.MC_FIRSTNAME || ' ' || taskcount.MC_LASTNAME AS MC,
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
    NVL(NEW_LEADS,0)           AS NEW_LEADS,
    NVL(CALLS,0)               AS CALLS,
    NVL(BOOKED,0)              AS BOOKED,
    NVL(BEBACK,0)              AS BEBACK,
    NVL(SHOWUPS,0)             AS SHOWUPS,
    NVL(WALKINS,0)             AS WALKINS,
    NVL(SALES,0)               AS SALES,
    NVL(WALKIN_SALE,0)               AS WALKIN_SALE,
    NVL(Booked_SALE,0)               AS Booked_SALE,
    NVL(Beback_SALE,0)               AS Beback_SALE,
    NVL(NO_TASK,0)               AS NO_TASK_SALE,
    NVL(ENDS,0)                AS ENDS,
    NVL( OTHERS,0)             AS OTHERS,
    NVL(AVG_DAYS_TO_END,0)  AS AVG_DAYS_TO_END,
    NVL(AVG_DAYS_TO_SALE,0) AS AVG_DAYS_TO_SALE,
    NVL(AVG_BOOK_TO_SALE,0) AS AVG_BOOK_TO_SALE
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
                    t.center                         AS CenterId,
                    c.SHORTNAME                      AS Club,
                    NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
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
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    t.center                         AS CenterId,
                    c.SHORTNAME                      AS Club,
                    NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                    NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
                    t.id as taskid,
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
LEFT JOIN
    (
        SELECT
            CENTERID,
            CLUB AS Club,
            MC_FIRSTNAME,
            MC_LASTNAME,
            "End"        AS AVG_DAYS_TO_END,
            "Sale"       AS AVG_DAYS_TO_SALE,
            "BookToSale" AS AVG_BOOK_TO_SALE
        FROM
            (
                SELECT
                    CENTERID,
                    CLUB,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    "Action",
                    AVG("CreationToAction") AS "Time"
                FROM
                    (
                        SELECT
                            t.center                         AS CENTERID,
                            c.SHORTNAME                      AS Club,
                            NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
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
                    "Action"
                UNION
                SELECT
                    CENTERID,
                    CLUB,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    'BookToSale'           AS "Action",
                    AVG("BookToAction") AS "Time"
                FROM
                    (
                        SELECT
                            t.center                         AS CENTERID,
                            c.SHORTNAME                      AS Club,
                            NVL( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                            NVL( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
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
                    MC_LASTNAME) pivot (SUM ("Time") FOR "Action" IN ('End'        AS "End",
                                                                      'Sale'       AS "Sale",
                                                                      'BookToSale' AS "BookToSale") )
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
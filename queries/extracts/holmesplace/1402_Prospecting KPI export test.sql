-- The extract is extracted from Exerp on 2026-02-08
--  


WITH
    recursive params AS
    /*+ materialize */
    (
        SELECT
            datetolong( TO_CHAR(DATE_TRUNC('month' ,CAST($$from_month$$ as DATE)),'YYYY-MM-DD') || ' 00:00') AS fromtime
            ,
            datetolong( TO_CHAR( DATE_TRUNC('month', CAST($$to_month$$ AS DATE) + interval '1 month') ,
            'YYYY-MM-DD') || ' 00:00') AS totime
    )
    ,
    month_list AS
    (
        SELECT
            TO_CHAR( start_date + interval '1 month' , 'MON' )    mon,
            1                                                  AS month_level
        FROM
            (
                SELECT
                    CAST($$from_month$$ AS DATE) start_date,
                    CAST($$to_month$$ AS DATE) end_date ) x
        UNION ALL
        SELECT
            TO_CHAR( start_date + interval '1 month' * (v.month_level-1) , 'MON' ) mon,
            v.month_level +                                                        1
        FROM
            (
                SELECT
                    CAST($$from_month$$ AS DATE) start_date,
                    CAST($$to_month$$ AS DATE) end_date ) x
        JOIN
            month_list v
        ON
            v.month_level <= extract('year' FROM age(DATE_TRUNC('month', end_date + interval
            '1 month') , DATE_TRUNC('month', start_date) ) )*12 + extract('month' FROM age
            (DATE_TRUNC('month', end_date + interval '1 month') , DATE_TRUNC('month', start_date) )
            )
    )
SELECT DISTINCT
    emp.CENTERID,
    c.SHORTNAME AS CLUB,
    c.COUNTRY,
    emp.MC_FIRSTNAME || ' ' || emp.MC_LASTNAME AS MC,
    month_list.MON                             AS "Month",
    COALESCE("LEAD",0)                           AS LEAD,
    COALESCE("LEAD_OVERDUE",0)                   AS LEAD_OVERDUE,
    COALESCE("HOT",0)                            AS HOT,
    COALESCE("HOT_OVERDUE",0)                    AS HOT_OVERDUE,
    COALESCE("WARM",0)                           AS WARM,
    COALESCE("WARM_OVERDUE",0)                   AS WARM_OVERDUE,
    COALESCE("COLD",0)                           AS COLD,
    COALESCE("COLD_OVERDUE",0)                   AS COLD_OVERDUE,
    COALESCE("FUTURE",0)                         AS FUTURE,
    COALESCE("FUTURE_OVERDUE",0)                 AS FUTURE_OVERDUE,
    COALESCE(NEW_LEADS,0)                      AS NEW_LEADS,
    COALESCE("Calls",0)                          AS CALLS,
    COALESCE(F_Bookings.Active_Bookings,0)     AS BOOKED,
    COALESCE(F_Bookings.Cancelled_Bookings,0)  AS CANCELLED_BOOKINGS,
    COALESCE("Beback",0)                         AS BEBACK,
    COALESCE(F_Bookings.showups,0)             AS SHOWUPS,
    COALESCE("Walkins",0)                        AS WALKINS,
    COALESCE("Sales",0)                          AS SALES,
    COALESCE("Suspect_Sale",0)                   AS Suspect_Sale,
    COALESCE(WALKIN_SALE,0)                    AS WALKIN_SALE,
    COALESCE(Booked_SALE,0)                    AS Booked_SALE,
    COALESCE(Beback_SALE,0)                    AS Beback_SALE,
    COALESCE(NO_TASK,0)                        AS NO_TASK_SALE,
    COALESCE("Ends",0)                           AS ENDS,
    COALESCE("OTHERS",0)                        AS OTHERS,
    COALESCE(AVG_DAYS_TO_END,0)                AS AVG_DAYS_TO_END,
    COALESCE(AVG_DAYS_TO_SALE,0)               AS AVG_DAYS_TO_SALE,
    COALESCE(AVG_BOOK_TO_SALE,0)               AS AVG_BOOK_TO_SALE,
    COALESCE(AVG_Days_To_Future,0)             AS Days_To_Future,
    COALESCE(F_Bookings.Books5Days,0)          AS Next_5_days_Bookings,
    COALESCE(no_CRM_sale.num,0)                AS No_CRM_SALE
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
                    OR  s.END_DATE IS NULL)
                AND s.center IN ($$scope$$)
                UNION ALL
                SELECT DISTINCT
                    t.center AS centerId,
                    'Unassigned',
                    'Unassigned'
                FROM
                    HP.TASKS t
                WHERE
                    t.center IN ($$scope$$) )x) emp
LEFT JOIN
    (
        SELECT
            centerid,
            MC_FIRSTNAME,
            MC_LASTNAME,
            SUM(
                CASE
                    WHEN category = 'LEAD'
                    THEN 1
                    ELSE 0
                END) AS "LEAD",
            SUM(
                CASE
                    WHEN category = 'LEAD_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS "LEAD_OVERDUE",
            SUM(
                CASE
                    WHEN category = 'HOT'
                    THEN 1
                    ELSE 0
                END) AS "HOT",
            SUM(
                CASE
                    WHEN category = 'HOT_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS "HOT_OVERDUE",
                SUM(
                CASE
                    WHEN category = 'WARM'
                    THEN 1
                    ELSE 0
                END) AS "WARM",
            SUM(
                CASE
                    WHEN category = 'WARM_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS "WARM_OVERDUE",
            SUM(
                CASE
                    WHEN category = 'COLD'
                    THEN 1
                    ELSE 0
                END) AS "COLD",
            SUM(
                CASE
                    WHEN category = 'COLD_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS "COLD_OVERDUE",
            SUM(
                CASE
                    WHEN category = 'FUTURE'
                    THEN 1
                    ELSE 0
                END) AS "FUTURE",
            SUM(
                CASE
                    WHEN category = 'FUTURE_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS "FUTURE_OVERDUE"
        FROM
            (
                SELECT
                    t.center                              AS centerid,
                    COALESCE( emp.FIRSTNAME,'Unassigned') AS MC_FIRSTNAME,
                    COALESCE( emp.LASTNAME,'Unassigned')  AS MC_LASTNAME,
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
                AND p.STATUS IN (0,6)
                AND t.STATUS NOT IN ('CLOSED',
                                     'DELETED')) x
        GROUP BY
            centerid,
            MC_FIRSTNAME,
            MC_LASTNAME) taskcount
ON
    emp.MC_FIRSTNAME = taskcount.MC_FIRSTNAME
AND emp.MC_LASTNAME = taskcount.MC_LASTNAME
AND emp.centerId = taskcount.centerId
CROSS JOIN
    month_list
LEFT JOIN
    (
        SELECT
            t.CENTER                                   AS CENTERID,
            COALESCE( emp.FIRSTNAME,'Unassigned')      AS MC_FIRSTNAME,
            COALESCE( emp.LASTNAME,'Unassigned')       AS MC_LASTNAME,
            TO_CHAR(longtodate(t.CREATION_TIME),'MON') AS MON,
            COUNT(t.id)                                AS NEW_LEADS
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
            emp.LASTNAME,
            TO_CHAR(longtodate(t.CREATION_TIME),'MON')
        ORDER BY
            t.CENTER,
            emp.FIRSTNAME,
            emp.LASTNAME ) LEADCOUNT
ON
    emp.centerid = leadcount.centerid
AND emp.MC_FIRSTNAME = leadcount.MC_FIRSTNAME
AND emp.MC_LASTNAME = leadcount.MC_LASTNAME
AND leadcount.MON = month_list.mon
LEFT JOIN
    (
        SELECT
            CenterId,
            MON,
            MC_FIRSTNAME,
            MC_LASTNAME,
            SUM(
                CASE
                    WHEN Action = 'Call'
                    THEN 1
                    ELSE 0
                END) AS "Calls",
            SUM(
                CASE
                    WHEN Action = 'Booked'
                    THEN 1
                    ELSE 0
                END) AS "Booked",
            SUM(
                CASE
                    WHEN Action = 'Beback'
                    THEN 1
                    ELSE 0
                END) AS "Beback",
            SUM(
                CASE
                    WHEN Action = 'ShowUp'
                    THEN 1
                    ELSE 0
                END) AS "ShowUps",
            SUM(
                CASE
                    WHEN Action = 'Sale'
                    THEN 1
                    ELSE 0
                END) AS "Sales",
            SUM(
                CASE
                    WHEN Action = 'Suspect_Sale'
                    THEN 1
                    ELSE 0
                END) AS "Suspect_Sale",
            SUM(
                CASE
                    WHEN Action = 'Walkin'
                    THEN 1
                    ELSE 0
                END) AS "Walkins",
            SUM(
                CASE
                    WHEN Action = 'End'
                    THEN 1
                    ELSE 0
                END) AS "Ends",
            SUM(
                CASE
                    WHEN Action = 'Other'
                    THEN 1
                    ELSE 0
                END) AS "OTHERS"
        FROM
            (
                SELECT
                    t.center                                 AS CenterId,
                    TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                    COALESCE( emp.FIRSTNAME,'Unassigned')    AS MC_FIRSTNAME,
                    COALESCE( emp.LASTNAME,'Unassigned')     AS MC_LASTNAME,
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
                                    OR  s.END_DATE IS NULL)
                                AND s.CREATION_TIME BETWEEN tl.ENTRY_TIME - 1000*60*60*24 AND
                                    tl.ENTRY_TIME + 1000* 60*60*24
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
                                    OR  s.END_DATE IS NULL)
                                AND s.CREATION_TIME BETWEEN tl.ENTRY_TIME - 1000*60*60*24 AND
                                    tl.ENTRY_TIME + 1000* 60*60*24
                                AND tl.TASK_ACTION_ID = 402)
                        THEN 'Suspect_Sale'
                        WHEN ta.id IN( 401,404,410)
                        THEN 'CALL'
                        WHEN ta.id IN ( 409)
                        THEN 'END'
                        WHEN ta.id IN ( 600)
                        THEN 'Walkin'
                        WHEN ta.id IN ( 400)
                        THEN 'Beback'
                        ELSE 'Other'
                    END AS Action
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
                AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime)x
        GROUP BY
            CenterId,
            MON,
            MC_FIRSTNAME,
            MC_LASTNAME,
            Action ) ACTIONCOUNT
ON
    emp.centerid = ACTIONCOUNT.centerid
AND emp.MC_FIRSTNAME = ACTIONCOUNT.MC_FIRSTNAME
AND emp.MC_LASTNAME = ACTIONCOUNT.MC_LASTNAME
AND ACTIONCOUNT.MON = month_list.mon
LEFT JOIN
    (
        SELECT
            CenterId,
            MC_FIRSTNAME,
            MC_LASTNAME,
            MON,
            SUM(
                CASE
                    WHEN "SALES" = 'Walkin Sale'
                    THEN 1
                    ELSE 0
                END) AS WALKIN_SALE,
            SUM(
                CASE
                    WHEN "SALES" = 'Walkin Sale'
                    THEN 1
                    ELSE 0
                END) AS Booked_SALE,
            SUM(
                CASE
                    WHEN "SALES" = 'Walkin Sale'
                    THEN 1
                    ELSE 0
                END) AS Beback_SALE,
            SUM(
                CASE
                    WHEN "SALES" = 'Walkin Sale'
                    THEN 1
                    ELSE 0
                END) AS NO_TASK
        FROM
            (
                SELECT
                    t.center                               AS CenterId,
                    COALESCE( emp.FIRSTNAME,'Unassigned')    AS MC_FIRSTNAME,
                    COALESCE( emp.LASTNAME,'Unassigned')     AS MC_LASTNAME,
                    t.id                                     AS taskid,
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
                            SUM(
                                CASE
                                    WHEN ta.id = 600
                                    THEN 1
                                    ELSE 0
                                END) AS WALKINS,
                            SUM(
                                CASE
                                    WHEN ta.id =400
                                    THEN 1
                                    ELSE 0
                                END) AS BEBACK,
                            SUM(
                                CASE
                                    WHEN ta.id =403
                                    THEN 1
                                    ELSE 0
                                END) AS BOOKED
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
                AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) x
        GROUP BY
            CenterId,
            MC_FIRSTNAME,
            MC_LASTNAME,
            MON ) SALESCOUNT
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
            ROUND(SUM(
                CASE
                    WHEN "Action" = 'END'
                    THEN "Time"
                    ELSE 0
                END) ,2) AS AVG_DAYS_TO_END,
            ROUND(SUM(
                CASE
                    WHEN "Action" = 'Sale'
                    THEN "Time"
                    ELSE 0
                END) ,2) AS AVG_DAYS_TO_SALE,
            ROUND(SUM(
                CASE
                    WHEN "Action" = 'BookToSale'
                    THEN "Time"
                    ELSE 0
                END) ,2) AS AVG_BOOK_TO_SALE,
            ROUND(SUM(
                CASE
                    WHEN "Action" = 'Future'
                    THEN "Time"
                    ELSE 0
                END) ,2) AS AVG_Days_To_Future,
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
                            t.center                              AS CENTERID,
                            COALESCE( emp.FIRSTNAME,'Unassigned')    AS MC_FIRSTNAME,
                            COALESCE( emp.LASTNAME,'Unassigned')     AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            COALESCE(ROUND((tl.ENTRY_TIME- t.CREATION_TIME)/(3600*24*1000) ,1),0)
                            AS "CreationToAction",
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
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) x
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
                            t.center                              AS CENTERID,
                            COALESCE( emp.FIRSTNAME,'Unassigned')    AS MC_FIRSTNAME,
                            COALESCE( emp.LASTNAME,'Unassigned')     AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            CASE
                                WHEN ta.id IN ( 402)
                                THEN
                                    (
                                        SELECT
                                            ROUND((tl.ENTRY_TIME-MAX(tl2.ENTRY_TIME))/(3600*24*1000
                                            ) ,1)
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
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) y
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
                            t.center                              AS CENTERID,
                            COALESCE( emp.FIRSTNAME,'Unassigned')    AS MC_FIRSTNAME,
                            COALESCE( emp.LASTNAME,'Unassigned')     AS MC_LASTNAME,
                            TO_CHAR(longtodate(tl.ENTRY_TIME),'MON') AS MON,
                            COALESCE(ROUND((tl.ENTRY_TIME- t.CREATION_TIME)/(3600*24*1000) ,1),0)
                                     AS "Future",
                            'Future' AS "Action"
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
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime) z
                GROUP BY
                    CENTERID,
                    MC_FIRSTNAME,
                    MC_LASTNAME,
                    MON ) x
        GROUP BY
            CENTERID,
            MC_FIRSTNAME,
            MC_LASTNAME,
            MON ) PERFORMANCE
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
            SUM(
                CASE
                    WHEN bo.STARTTIME BETWEEN dateToLong(TO_CHAR(CURRENT_DATE, 'YYYY-MM-dd HH24:MI'
                        )) AND dateToLong(TO_CHAR(CURRENT_DATE + interval '5 day',
                        'YYYY-MM-dd HH24:MI'))
                    THEN 1
                END )AS Books5Days,
            SUM(
                CASE
                    WHEN bo.CREATION_TIME BETWEEN params.fromtime AND params.totime
                    AND bo.STATE = 'CANCELLED'
                    THEN 1
                END )AS Cancelled_Bookings,
            SUM(
                CASE
                    WHEN bo.CREATION_TIME BETWEEN params.fromtime AND params.totime
                    AND bo.STATE = 'ACTIVE'
                    THEN 1
                END )AS Active_Bookings,
            SUM(
                CASE
                    WHEN bo.CREATION_TIME BETWEEN params.fromtime AND params.totime
                    AND par.STATE = 'PARTICIPATION'
                    THEN 1
                END )AS showups
        FROM
            HP.BOOKINGS bo
        CROSS JOIN
            params
        JOIN
            STAFF_USAGE su
        ON
            su.BOOKING_CENTER = bo.CENTER
        AND su.BOOKING_ID = bo.ID
        JOIN
            HP.PERSONS p
        ON
            p.CENTER = su.PERSON_CENTER
        AND p.id = su.PERSON_ID
        JOIN
            HP.ACTIVITY ac
        ON
            ac.id = bo.ACTIVITY
        LEFT JOIN
            HP.PARTICIPATIONS par
        ON
            par.BOOKING_CENTER=bo.CENTER
        AND par.BOOKING_ID = bo.id
        WHERE
            bo.STARTTIME > params.fromtime
            --AND bo.STATE = 'ACTIVE'
        AND ac.ACTIVITY_GROUP_ID = 1803
        AND bo.center IN ($$scope$$)
        GROUP BY
            p.FIRSTNAME,
            p.LASTNAME,
            bo.CENTER ) F_Bookings
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
            TO_CHAR(longtodate(s.CREATION_TIME),'MON')         MON,
            COUNT(DISTINCT s.OWNER_CENTER||'p'||s.OWNER_ID) AS num
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
            OR  s.END_DATE IS NULL)
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
                AND tl.ENTRY_TIME BETWEEN s.CREATION_TIME - 1000*60*60*24 AND s.CREATION_TIME +
                    1000*60*60*24)
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
                    OR  s2.END_DATE IS NULL)
                AND s2.CREATION_TIME< s.CREATION_TIME
                AND (
                        s2.END_DATE > add_months(s.START_DATE,-3)
                    OR  s2.END_DATE IS NULL))
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
OR  ACTIONCOUNT.MC_FIRSTNAME IS NOT NULL
OR  PERFORMANCE.MC_FIRSTNAME IS NOT NULL
OR  no_CRM_sale.FIRSTNAME IS NOT NULL
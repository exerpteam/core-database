-- The extract is extracted from Exerp on 2026-02-08
--  


WITH
    params AS
    (
        SELECT
            :fromdate              AS fromtime,
            :todate + 24*3600*1000 AS totime
        
    )
SELECT
    CLUB         AS "Club",
    MC           AS "MC",
    "End"        AS "Median days to End",
    "Sale"       AS "Median days to sale",
    "BookToSale" AS "Median days book to sale"
FROM
    (
        SELECT
            CLUB,
            MC,
            SUM(
                CASE
                    WHEN "Action" = 'End'
                    THEN "Time"
                    ELSE 0
                END) AS "End",
            SUM(
                CASE
                    WHEN "Action" = 'Sale'
                    THEN "Time"
                    ELSE 0
                END) AS "Sale",
            SUM(
                CASE
                    WHEN "Action" = 'BookToSale'
                    THEN "Time"
                    ELSE 0
                END) AS "BookToSale"
        FROM
            (
                SELECT
                    CLUB,
                    MC,
                    "Action",
                    percentile_disc(0.5) within group (order by "CreationToAction") AS "Time" --Calculate median
                FROM
                    (
                        SELECT
                            c.SHORTNAME                        AS Club,
                            COALESCE(emptask.fullname,'Unassigned') AS MC,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
                            COALESCE(ROUND((tl.ENTRY_TIME- t.CREATION_TIME)/(3600*24*1000) ,1),0) AS
                            "CreationToAction",
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
                            emp.center = tl.EMPLOYEE_CENTER
                        AND emp.id = tl.EMPLOYEE_ID
                        LEFT JOIN
                            HP.persons emptask
                        ON
                            emptask.center = t.ASIGNEE_CENTER
                        AND emptask.id = t.ASIGNEE_ID
                        WHERE
                            t.center IN (:scope)
                        AND t.TYPE_ID = 200
                        AND ta.ID IN (402,409)
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) x
                GROUP BY
                    CLUB,
                    MC,
                    "Action"
                UNION
                SELECT
                    CLUB,
                    MC,
                    'BookToSale'           AS "Action",
                    percentile_disc(0.5) within group (order by "BookToAction") AS "Time"
                FROM
                    (
                        SELECT
                            c.SHORTNAME                        AS Club,
                            COALESCE(emptask.fullname,'Unassigned') AS MC,
                            /**ta.name                                              AS actionname,
                            ta.id                                                AS actionid,**/
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
                            emp.center = tl.EMPLOYEE_CENTER
                        AND emp.id = tl.EMPLOYEE_ID
                        LEFT JOIN
                            HP.persons emptask
                        ON
                            emptask.center = t.ASIGNEE_CENTER
                        AND emptask.id = t.ASIGNEE_ID
                        WHERE
                            t.center IN (:scope)
                        AND t.TYPE_ID = 200
                        AND ta.ID IN (402)
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime ) y
                GROUP BY
                    CLUB,
                    MC )z
        GROUP BY
            CLUB,
            MC) piv
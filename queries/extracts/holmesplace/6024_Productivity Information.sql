

WITH
    params AS
    (
        SELECT
            :fromdate AS fromtime,
            :todate   AS totime
    )
SELECT
    "Club",
    MC as "MC",
    COALESCE("New",0)    AS "New leads" ,
    COALESCE("Call",0)   AS "Calls",
    COALESCE("Booked",0) AS "Appointments booked",
    COALESCE("ShowUp",0) AS "Appointments shows",
    COALESCE("End",0)    AS "End" ,
    COALESCE("Sale",0)   AS "Sale"
FROM
    (
        SELECT
            "Club",
            MC,
            SUM(
                CASE
                    WHEN "Action" = 'New'
                    THEN "Count"
                    ELSE 0
                END) AS "New",
            SUM(
                CASE
                    WHEN "Action" = 'Call'
                    THEN "Count"
                    ELSE 0
                END) AS "Call",
            SUM(
                CASE
                    WHEN "Action" = 'Booked'
                    THEN "Count"
                    ELSE 0
                END) AS "Booked",
            SUM(
                CASE
                    WHEN "Action" = 'ShowUp'
                    THEN "Count"
                    ELSE 0
                END) AS "ShowUp",
            SUM(
                CASE
                    WHEN "Action" = 'Sale'
                    THEN "Count"
                    ELSE 0
                END) AS "Sale",
            SUM(
                CASE
                    WHEN "Action" = 'End'
                    THEN "Count"
                    ELSE 0
                END) AS "End"
        FROM
            (
                SELECT
                    c.shortname                         AS "Club",
                    COALESCE(emp.FULLNAME,'Unassigned') AS MC,
                    'New'                               AS "Action",
                    COUNT(t.id)                         AS "Count"
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
                    t.center IN (:scope)
                AND t.TYPE_ID = 200
                AND t.CREATION_TIME BETWEEN params.fromtime AND params.totime
                GROUP BY
                    c.shortname,
                    emp.fullname
                UNION
                SELECT
                    Club,
                    MC,
                    /**actionname,
                    actionid,**/
                    "Action",
                    COUNT(logid) AS "Count"
                FROM
                    (
                        SELECT
                            c.SHORTNAME                                                    AS Club,
                            COALESCE(emp.FULLNAME,COALESCE(emptask.fullname,'Unassigned')) AS MC,
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
                        AND ta.ID IN (401,402,403,404,407,409,410)
                        AND tl.ENTRY_TIME BETWEEN params.fromtime AND params.totime) x
                GROUP BY
                    Club,
                    MC,
                    "Action" )p
        GROUP BY
            "Club",
            MC)x
ORDER BY
    "Club",
    "MC"

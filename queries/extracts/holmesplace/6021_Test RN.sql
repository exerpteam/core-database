SELECT
    *
FROM
    (
        SELECT
            c.shortname,
            NVL( emp.FULLNAME,'Unassigned') AS MC,
            CASE
                WHEN (p.status = 0)
                THEN 'LEAD'
                WHEN (p.status = 6 )
                THEN tg.EXTERNAL_ID ||
                    CASE
                        WHEN (t.status = 'OVERDUE')
                        THEN '_OVERDUE'
                        ELSE ''
                    END
                ELSE 'OTHER'
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
            c.id = t.center
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
        AND t.center = 49
        AND
            -- LEAD: 0 , PROSPECT: 6
            p.STATUS IN (0,6)
        AND t.STATUS NOT IN ('CLOSED',
                             'DELETED') ) PIVOT (COUNT(id) AS nb_tasks FOR (category) IN ( 'LEAD'
                                                                                           AS LEAD ,
                                                                                          'WARM' AS
                                                                                          WARM ,
                                                                                          'WARM_OVERDUE'
                                                                                          AS
                                                                                          WARM_OVERDUE
                                                                                          ,
                                                                                          'COLD' AS
                                                                                          COLD ,
                                                                                          'COLD_OVERDUE'
                                                                                          AS
                                                                                          COLD_OVERDUE
                                                                                          ,
                                                                                          'FUTURE'
                                                                                          AS FUTURE
                                                                                          ,
                                                                                          'FUTURE_OVERDUE'
                                                                                          AS
                                                                                          FUTURE_OVERDUE
                                                                                          ,
                                                                                          'HOT' AS
                                                                                          HOT ,
                                                                                          'HOT_OVERDUE'
                                                                                          AS
                                                                                          HOT_OVERDUE
                                                                                          ) )
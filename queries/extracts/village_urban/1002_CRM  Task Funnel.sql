SELECT
    pro.RANK AS "Progress Rank",
    pro.NAME AS "Progress Category",
    sum(decode(tasks.rank,null,0,1)) AS "Tasks in step"
FROM
    VU.PROGRESS pro
LEFT JOIN
    (
        SELECT DISTINCT
            pro.RANK ,
            pro.NAME,
            tl.TASK_ID
        FROM
            TASK_LOG tl
        JOIN
            TASK_STEPS ts
        ON
            ts.ID = tl.TASK_STEP_ID
        JOIN
            PROGRESS PRO
        ON
            pro.ID = ts.PROGRESS_ID
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    TASK_LOG tl2
                WHERE
                    tl.id = tl2.PREVIOUS_TASK_LOG_ID
                    AND tl2.ENTRY_TIME < :SetDate)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    tasks t
                WHERE
                    tl.TASK_ID = t.ID
                    AND t.STATUS = 'CLOSED'
                    AND t.LAST_UPDATE_TIME < :SetDate)
            AND tl.ENTRY_TIME < :SetDate
        UNION
        SELECT DISTINCT
            pro.RANK ,
            pro.NAME ,
            t.ID AS TASK_ID
        FROM
            TASKS t
        JOIN
            TASK_STEPS ts
        ON
            ts.ID = t.STEP_ID
        JOIN
            PROGRESS PRO
        ON
            pro.ID = ts.PROGRESS_ID
        WHERE
            T.STATUS = 'CLOSED'
            AND t.LAST_UPDATE_TIME < :SetDate ) tasks
ON
    tasks.name = pro.NAME
GROUP BY
    pro.rank,
    pro.name
ORDER BY
    pro.rank
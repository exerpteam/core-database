SELECT
    commentTime dat,
    assigned,
    todogroup,
    SUM(created) creations,
    SUM(updated) updates,
    SUM(deleted) deletions,
    SUM(reopened) reopened,
    SUM(completed) completed
FROM
    (
        SELECT
            td.center || 'td' || td.id id,
            tg.NAME todogroup,
            --td.SUBJECT,
            creator.FULLNAME creator,
            assignedto.FULLNAME assigned,
            person.FULLNAME person,
            --DECODE(td.STATUS, 1, 'NOT_STARTED', 2, 'IN_PROGRESS', 3, 'COMPLETED', 4, 'WAITING', 5, 'REJECTED', 6, '
            -- DELETED',
            -- 'UNKNOWN') status,
            --TO_CHAR(longtodate(td.CREATION_TIME), 'YYYY-MM-DD') creation,
            --TO_CHAR(longtodate(td.DEADLINE), 'YYYY-MM-DD') deadline,
            --DECODE(td.TODO_TYPE, 0, 'MEMBER', 1, 'COMPANY', 2, 'STAFF', 'UNKNOWN') type,
            TO_CHAR(longtodate(tc.COMMENT_TIME), 'YYYY-MM-DD') commentTime,
            CASE
                WHEN tc.ACTION = 'CREATED'
                THEN 1
            END created,
            CASE
                WHEN tc.ACTION = 'COMMENT'
                    OR tc.ACTION = 'NOTE'
                THEN 1
            END updated,
            CASE
                WHEN tc.ACTION = 'DELETED'
                THEN 1
            END deleted,
            CASE
                WHEN tc.ACTION = 'REOPENED'
                THEN 1
            END reopened,
            CASE
                WHEN tc.ACTION = 'COMPLETED'
                THEN 1
            END completed,
            tc.COMENT
        FROM
            PULSE.TODOS td
        JOIN PULSE.TODO_GROUPS tg
        ON
            td.TODO_GROUP_ID = tg.ID
        JOIN PULSE.PERSONS creator
        ON
            td.CREATORCENTER = creator.CENTER
            AND td.CREATORID = creator.ID
        JOIN PULSE.PERSONS assignedto
        ON
            td.ASSIGNEDTOCENTER = assignedto.CENTER
            AND td.ASSIGNEDTOID = assignedto.ID
        LEFT JOIN PULSE.TODOCOMMENTS tc
        ON
            tc.CENTER = td.CENTER
            AND tc.id = td.id
        LEFT JOIN PULSE.PERSONS person
        ON
            td.PERSONCENTER = person.CENTER
            AND td.PERSONID = person.ID
        LEFT JOIN PULSE.PARTICIPATIONS par
        ON
            par.PARTICIPANT_CENTER = td.PERSONCENTER
            AND par.PARTICIPANT_ID = td.PERSONID
            AND par.CREATION_BY_CENTER = td.ASSIGNEDTOCENTER
            AND par.CREATION_BY_ID = td.ASSIGNEDTOID
            AND TO_CHAR(longtodate(par.CREATION_TIME), 'YYYY-MM-DD') = TO_CHAR(longtodate(tc.COMMENT_TIME),
            'YYYY-MM-DD')
        WHERE
            tc.COMMENT_TIME > :FromDate
            AND tc.COMMENT_TIME < :ToDate + 60*60*1000*24
            AND td.CENTER in (:Scope)
        ORDER BY
            td.CENTER,
            td.ID,
            tc.COMMENT_TIME
    )
GROUP BY
    commentTime,
    assigned,
    todogroup
ORDER BY
    2,1
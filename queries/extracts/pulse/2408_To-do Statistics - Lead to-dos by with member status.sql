SELECT
    td.center || 'td' || td.id id,
    tg.NAME todogroup,
    creator.FULLNAME creator,
    assignedto.FULLNAME assigned,
    person.CENTER || 'p' || person.ID personId,
    person.FULLNAME person,
    DECODE(td.STATUS, 1, 'NOT_STARTED', 2, 'IN_PROGRESS', 3, 'COMPLETED', 4, 'WAITING', 5, 'REJECTED', 6, 'DELETED',
    'UNKNOWN') todo_status,
    TO_CHAR(longtodate(td.CREATION_TIME), 'YYYY-MM-DD') creation,
    TO_CHAR(longtodate(td.DEADLINE), 'YYYY-MM-DD') deadline,
    DECODE (person.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,
    'PROSPECT', 7,'DELETED','UNKNOWN') AS PERSON_STATUS,
    prod.NAME MEMBERSHIP,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD') startdate
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
JOIN PULSE.PERSONS person
ON
    td.PERSONCENTER = person.CENTER
    AND td.PERSONID = person.ID
LEFT JOIN PULSE.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = person.CENTER
    AND s.OWNER_ID = person.ID
    AND s.STATE in (2,4)
LEFT JOIN PULSE.PRODUCTS prod
ON
    s.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = prod.ID
WHERE
    td.CENTER IN (:Scope)
    /* Lead todo groups */
    AND td.TODO_GROUP_ID IN (1,2,3,4,5)
    /* Only member todos */
    AND td.TODO_TYPE = 0
    AND EXISTS
    (
        SELECT
            *
        FROM
            PULSE.TODOCOMMENTS tc
        WHERE
            tc.CENTER = td.CENTER
            AND tc.id = td.id
            AND tc.COMMENT_TIME > :FromDate
            AND tc.COMMENT_TIME < :ToDate + 60*60*1000*24
    )
ORDER BY
    td.CENTER,
    td.ID
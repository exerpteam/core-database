-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    'BOOKING' TYPE,
    /* TO_CHAR(b.ID) booking_id, */
    TO_CHAR(longToDate(b.STARTTIME),'YYYY-MM-DD HH24:MI') "FROM",
    TO_CHAR(longToDate(b.STOPTIME),'YYYY-MM-DD HH24:MI')  "TO",
    REPLACE(b.COMENT,';','@@semicolon@@')                         "COMMENT",
    b.OWNER_CENTER || 'p' || b.OWNER_ID                                  PROSPECT,
    REPLACE(cust.FULLNAME,';','@@semicolon@@')                           PROSPECT_NAME
FROM
    BOOKINGS b
JOIN
    ACTIVITY a
ON
    a.ID = b.ACTIVITY
JOIN
    PERSONS cust
ON
    cust.CENTER = b.OWNER_CENTER
    AND cust.ID = b.OWNER_ID
JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = b.CENTER
    AND par.BOOKING_ID = b.ID
    AND par.PARTICIPANT_CENTER = cust.CENTER
    AND par.PARTICIPANT_ID = cust.ID
JOIN
    STAFF_USAGE su
ON
    su.BOOKING_CENTER = b.CENTER
    AND su.BOOKING_ID = b.ID
JOIN
    PERSONS staff
ON
    staff.CENTER = su.PERSON_CENTER
    AND staff.ID = su.PERSON_ID
WHERE
    (
        staff.center,staff.id) IN ($$PID$$)
    AND TRUNC(longToDate(b.STARTTIME)) = TRUNC(SYSDATE)
UNION ALL
SELECT
    'CRM'                                     TYPE,
    TO_CHAR(t.FOLLOW_UP,'YYYY-MM-DD HH24:MI') "FROM",
    NULL                                      "TO",
    NULL                                      "COMMENT",
    p.CENTER || 'p' || p.ID                   PROSPECT,
    p.FULLNAME                                PROSPECT_NAME
FROM
    TASKS t
JOIN
    TASK_STEPS ts
ON
    ts.ID = t.STEP_ID
JOIN
    PERSONS p
ON
    p.CENTER = t.PERSON_CENTER
    AND p.ID = t.PERSON_ID
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = t.ASIGNEE_CENTER
    AND emp.ID = t.ASIGNEE_ID
WHERE
    (
        emp.CENTER,emp.ID) IN ($$PID$$)
    AND (
        t.STATUS IN ('OPEN',
                     'OVERDUE')
        OR TRUNC(t.FOLLOW_UP) = TRUNC(SYSDATE ))
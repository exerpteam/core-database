-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
           (TRUNC(SYSDATE) - :offset - to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS')) * 24 * 3600 * 1000 AS FROMDATE
          , (TRUNC(SYSDATE+1) - to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS')) * 24 * 3600 * 1000            AS TODATE
        FROM
            DUAL
    )
SELECT
    p.external_id              AS "External ID",
   -- p.center ||'p'|| p.id      AS "Member ID",
    e.center||'emp'||e.id      AS "Staff number",
    staff.fullname             AS "Staff name",
    longtodate(pcl.ENTRY_TIME) AS "Date of update"
FROM
    PERSON_CHANGE_LOGS pcl
CROSS JOIN
    params
JOIN
    Persons p
ON
    p.center = pcl.PERSON_CENTER
    AND p.id = pcl.PERSON_ID
JOIN
    EMPLOYEES e
ON
    e.center = pcl.EMPLOYEE_CENTER
    AND e.id = pcl.EMPLOYEE_ID
    AND e.center || 'emp' || e.id NOT IN ('114emp813',
                                          '100emp1')
JOIN
    Persons staff
ON
    e.personcenter = staff.center
    AND e.personid = staff.id
WHERE
    pcl.person_center IN (:Scope)
    AND pcl.ENTRY_TIME >= params.FromDate
    AND pcl.ENTRY_TIME <= params.ToDate
    AND pcl.PREVIOUS_ENTRY_ID IS NOT NULL
    AND pcl.CHANGE_ATTRIBUTE = 'LAST_NAME'
    AND EXISTS
    (
        SELECT
            pcl2.CHANGE_ATTRIBUTE
        FROM
            PERSON_CHANGE_LOGS pcl2
        WHERE
            pcl2.CHANGE_ATTRIBUTE = 'FIRST_NAME'
            AND pcl2.ENTRY_TIME >= params.FromDate
            AND pcl2.ENTRY_TIME <= params.ToDate
            AND p.center = pcl2.PERSON_CENTER
            AND p.id = pcl2.PERSON_ID
            AND pcl2.PREVIOUS_ENTRY_ID IS NOT NULL)
    AND EXISTS
    (
        SELECT
            pcl3.CHANGE_ATTRIBUTE
        FROM
            PERSON_CHANGE_LOGS pcl3
        WHERE
            pcl3.CHANGE_ATTRIBUTE = 'BIRTHDATE'
            AND pcl3.ENTRY_TIME >= params.FromDate
            AND pcl3.ENTRY_TIME <= params.ToDate
            AND p.center = pcl3.PERSON_CENTER
            AND p.id = pcl3.PERSON_ID
            AND pcl3.PREVIOUS_ENTRY_ID IS NOT NULL)
SELECT
    ei.ID AS "ID",
    CASE
        WHEN ei.IDMETHOD = 1
        THEN 'BARCODE'
        WHEN ei.IDMETHOD = 2
        THEN 'MAGNETIC_CARD'
        WHEN ei.IDMETHOD = 3
        THEN 'SSN'
        WHEN ei.IDMETHOD = 4
        THEN 'RFID_CARD'
        WHEN ei.IDMETHOD = 5
        THEN 'PIN'
        WHEN ei.IDMETHOD = 6
        THEN 'ANTI DROWN'
        WHEN ei.IDMETHOD = 7
        THEN 'QRCODE'
        ELSE 'UNKNOWN'
    END         AS "TYPE",
    ei.identity AS "ENTITY_ID_VALUE",
    CASE
        WHEN (person.CENTER != person.TRANSFERS_CURRENT_PRS_CENTER
            OR  person.id != person.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = person.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = person.TRANSFERS_CURRENT_PRS_ID)
        ELSE person.EXTERNAL_ID
    END AS "PERSON_ID",
    CASE
        WHEN ei.ENTITYSTATUS = 1
        THEN 'OK'
        WHEN ei.ENTITYSTATUS = 2
        THEN 'STOLEN'
        WHEN ei.ENTITYSTATUS = 3
        THEN 'MISSING'
        WHEN ei.ENTITYSTATUS = 4
        THEN 'BLOCKED'
        WHEN ei.ENTITYSTATUS = 5
        THEN 'BROKEN'
        WHEN ei.ENTITYSTATUS = 6
        THEN 'RETURNED'
        WHEN ei.ENTITYSTATUS = 7
        THEN 'EXPIRED'
        WHEN ei.ENTITYSTATUS = 8
        THEN 'DELETED'
        WHEN ei.ENTITYSTATUS = 9
        THEN 'COMPROMISED'
        WHEN ei.ENTITYSTATUS = 10
        THEN 'FORGOTTEN'
        WHEN ei.ENTITYSTATUS = 11
        THEN 'BANNED'
        ELSE 'UNKNOWN'
    END           AS "STATUS",
    ei.START_TIME AS "START_DATETIME",
    ei.STOP_TIME  AS "STOP_DATETIME",
    CASE
        WHEN (assign_person.CENTER != assign_person.TRANSFERS_CURRENT_PRS_CENTER
            OR  assign_person.id != assign_person.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = assign_person.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = assign_person.TRANSFERS_CURRENT_PRS_ID)
        ELSE assign_person.EXTERNAL_ID
    END AS "ASSIGN_PERSON_ID",
    CASE
        WHEN (block_person.CENTER != block_person.TRANSFERS_CURRENT_PRS_CENTER
            OR  block_person.id != block_person.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = block_person.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = block_person.TRANSFERS_CURRENT_PRS_ID)
        ELSE block_person.EXTERNAL_ID
    END AS                                "BLOCK_PERSON_ID",
    ei.ref_center                      AS "CENTER_ID",
    ei.last_modified                   AS "ETS"
FROM
    ENTITYIDENTIFIERS ei
LEFT JOIN
    PERSONS person
ON
    person.center = ei.REF_CENTER
    AND person.ID = ei.REF_ID
LEFT JOIN
    employees assign_emp
ON
    assign_emp.center = ei.ASSIGN_EMPLOYEE_CENTER
AND assign_emp.ID = ei.ASSIGN_EMPLOYEE_ID
LEFT JOIN
    PERSONS assign_person
ON
    assign_person.center = assign_emp.personcenter
AND assign_person.ID = assign_emp.personid
LEFT JOIN
    employees block_emp
ON
    block_emp.center = ei.BLOCK_EMPLOYEE_CENTER
AND block_emp.ID = ei.BLOCK_EMPLOYEE_ID
LEFT JOIN
    PERSONS block_person
ON
    block_person.center = block_emp.personcenter
AND block_person.ID = block_emp.personid
WHERE 
   ei.REF_TYPE = 1 AND person.status <> 5

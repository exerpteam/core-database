SELECT
    emp.center||'emp'||emp.id AS "ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                                          AS "PERSON_ID",
    CAST(CAST ( emp.blocked AS INT) AS SMALLINT) AS "BLOCKED",
    emp.external_id                              AS "EXTERNAL_ID",
    emp.center                                   AS "CENTER_ID"
FROM
    employees emp
JOIN
    persons p
ON
    p.center = emp.personcenter
    AND p.id = emp.personid
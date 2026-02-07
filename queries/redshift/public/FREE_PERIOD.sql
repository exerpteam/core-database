SELECT
    srp.ID                                         AS "ID",
    srp.SUBSCRIPTION_CENTER||'ss'||SUBSCRIPTION_ID AS "SUBSCRIPTION_ID",
    srp.SUBSCRIPTION_CENTER                        AS "SUBSCRIPTION_CENTER_ID",
    srp.START_DATE                                 AS "START_DATE",
    srp.END_DATE                                   AS "END_DATE",
    srp.STATE                                      AS "STATE",
    srp.TYPE                                       AS "TYPE",
    srp.TEXT                                       AS "REASON",
    srp.ENTRY_TIME                                 AS "ENTRY_DATETIME",
    srp.CANCEL_TIME         AS "CANCEL_DATETIME",
    srp.SUBSCRIPTION_CENTER AS "CENTER_ID",
        CASE
        WHEN emp.id IS NOT NULL
        THEN
            CASE
                WHEN (employee_person.CENTER != employee_person.TRANSFERS_CURRENT_PRS_CENTER
                    AND employee_person.id != employee_person.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            persons
                        WHERE
                            CENTER = employee_person.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = employee_person.TRANSFERS_CURRENT_PRS_ID)
                ELSE employee_person.EXTERNAL_ID
            END
        ELSE NULL
    END                     AS "CREATOR_PERSON_ID",
    srp.LAST_MODIFIED       AS "ETS"
FROM
    SUBSCRIPTION_REDUCED_PERIOD srp
LEFT JOIN
    employees emp
ON
    emp.center=srp.employee_center
AND emp.id=srp.employee_id
LEFT JOIN
    persons employee_person
ON
    employee_person.center = emp.personcenter
AND employee_person.id = emp.personid


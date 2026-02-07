SELECT
    f.ID                                               "ID",
    f.SUBSCRIPTION_CENTER || 'ss' || f.SUBSCRIPTION_ID "SUBSCRIPTION_ID",
    f.SUBSCRIPTION_CENTER                              "SUBSCRIPTION_CENTER_ID",
    f.START_DATE                                       "START_DATE",
    f.END_DATE                                         "END_DATE",
    f.STATE AS                                         "STATE",
    f.TYPE  AS                                         "TYPE",
    f.TEXT                                             "REASON",
    f.ENTRY_TIME          AS                                    "ENTRY_DATETIME",
    f.CANCEL_TIME         AS                                    "CANCEL_DATETIME",
    f.SUBSCRIPTION_CENTER AS                                    "CENTER_ID",
    CASE
        WHEN staff.SEX != 'C'
        THEN
            CASE
                WHEN (staff.CENTER != staff.TRANSFERS_CURRENT_PRS_CENTER
                    OR  staff.id != staff.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            persons
                        WHERE
                            CENTER = staff.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = staff.TRANSFERS_CURRENT_PRS_ID)
                ELSE staff.EXTERNAL_ID
            END
        ELSE NULL
    END AS          "CREATOR_PERSON_ID",
    f.LAST_MODIFIED "ETS"
FROM
    SUBSCRIPTION_FREEZE_PERIOD f
LEFT JOIN
    employees emp
ON
    emp.center = f.employee_center
AND emp.id = f.employee_id
LEFT JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid

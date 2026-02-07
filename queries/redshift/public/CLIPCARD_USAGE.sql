SELECT
    cc_usage.ID                                                             AS "ID",
    cc_usage.CARD_CENTER||'cc'||cc_usage.CARD_ID||'cc'||cc_usage.CARD_SUBID AS "CLIPCARD_ID",
    cc_usage.TYPE                                                           AS "TYPE",
    cc_usage.STATE                                                          AS "STATE",
    CASE
        WHEN (staff.CENTER != staff.TRANSFERS_CURRENT_PRS_CENTER
                OR staff.id != staff.TRANSFERS_CURRENT_PRS_ID)
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = staff.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = staff.TRANSFERS_CURRENT_PRS_ID)
        ELSE staff.EXTERNAL_ID
    END                                AS "EMPLOYEE_PERSON_ID",
    cc_usage.CLIPS                     AS "CLIPS",
    cc_usage.clipcard_usage_commission AS "COMMISSION_UNITS",
    cc_usage.TIME                      AS "USAGE_DATETIME",
    cc_usage.cancellation_timestamp    AS "CANCELLATION_DATETIME",
    cc_usage.activation_timestamp      AS "ACTIVATION_DATETIME",
    cc_usage.CARD_CENTER               AS "CENTER_ID",
    cc_usage.LAST_MODIFIED             AS "ETS"
FROM
    CARD_CLIP_USAGES cc_usage
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = cc_usage.EMPLOYEE_CENTER
    AND emp.id = cc_usage.EMPLOYEE_ID
LEFT JOIN
    PERSONS staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID

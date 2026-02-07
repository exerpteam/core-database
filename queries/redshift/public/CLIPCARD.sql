SELECT
    cc.center||'cc'||cc.id||'cc'||cc.SUBID AS "ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
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
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE
        WHEN P.SEX = 'C'
        THEN
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
            END
        ELSE NULL
    END                                                                         AS "COMPANY_ID",
    cc.CLIPS_LEFT                                                               AS "CLIPS_LEFT",
    cc.CLIPS_INITIAL                                                            AS "CLIPS_INITIAL",
    cc.INVOICELINE_CENTER||'inv'||cc.INVOICELINE_ID||'ln'||cc.INVOICELINE_SUBID AS "SALE_LOG_ID",
    cc.VALID_FROM                                                               AS "VALID_FROM_DATETIME",
    cc.VALID_UNTIL                                                              AS "VALID_UNTIL_DATETIME",
    CAST(CAST (cc.BLOCKED AS INT) AS SMALLINT)                                  AS "BLOCKED",
    CAST(CAST (cc.CANCELLED AS INT) AS SMALLINT)                                AS "CANCELLED",
    cc.CANCELLATION_TIME                                                        AS "CANCEL_DATETIME",
    CASE
        WHEN (staff.CENTER != staff.TRANSFERS_CURRENT_PRS_CENTER
                OR staff.id != staff.TRANSFERS_CURRENT_PRS_ID )
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
    END              AS "ASSIGNED_PERSON_ID",
    cc.cc_comment    AS "COMMENT",
	CASE WHEN cc.refmain_center IS NOT NULL
		THEN cc.refmain_center||'ss'||cc.refmain_id  
		ELSE null
	END AS "RECURRENCE_SUBSCRIPTION_ID",
    cc.center||'prod'||cc.id    AS "PRODUCT_ID",
    CASE WHEN cc.TRANSFER_FROM_CLIPCARD_CENTER IS NOT NULL THEN
        cc.TRANSFER_FROM_CLIPCARD_CENTER ||'cc'|| cc.TRANSFER_FROM_CLIPCARD_ID ||'cc'|| cc.TRANSFER_FROM_CLIPCARD_SUBID
    ELSE NULL END AS "TRANSFER_CLIPCARD_ID",    
    cc.center                   AS "CENTER_ID",
    cc.LAST_MODIFIED            AS "ETS"
FROM
    CLIPCARDS cc
LEFT JOIN
    PERSONS p
ON
    p.center = cc.OWNER_CENTER
    AND p.id = cc.OWNER_ID
LEFT JOIN
    persons staff
ON
    staff.center = cc.assigned_staff_center
    AND staff.id = cc.assigned_staff_id

SELECT
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
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
    END                                              AS "PERSON_ID",
    CAST ( cc_usage.ID AS VARCHAR(255))                                     AS "CLIPCARD_USAGES.ID",
    cc_usage.CARD_CENTER||'cc'||cc_usage.CARD_ID||'id'||cc_usage.CARD_SUBID AS
                                              "CLIPCARD_USAGES.CLIPCARD_ID",
    il.PRODUCTCENTER||'prod'||il.PRODUCTID                  AS "CLIPCARD_USAGES.CLIPCARD_PRODUCT_ID",
    cc_usage.TYPE                                              AS "CLIPCARD_USAGES.TYPE",
    cc_usage.STATE                                             AS "CLIPCARD_USAGES.STATE",
    cstaff.EXTERNAL_ID                                         AS "CLIPCARD_USAGES.EMPLOYEE_ID",
    CAST ( cc_usage.CLIPS AS VARCHAR(255))                     AS "CLIPCARD_USAGES.CLIPS",
    CAST ( cc_usage.clipcard_usage_commission AS VARCHAR(255)) AS "CLIPCARD_USAGES.COMMISSION_UNITS"
    ,
    TO_CHAR(longtodatetz(cc_usage.TIME,cen.TIME_ZONE),'dd.MM.yyyy HH24:MI:SS') AS
                                                    "CLIPCARD_USAGES.USAGE_TIME",
    CAST ( cc_usage.CARD_CENTER AS VARCHAR(255))                      AS "CLIPCARD_USAGES.CENTER_ID",
    TO_CHAR(longtodatetz(cc_usage.LAST_MODIFIED, cen.TIME_ZONE), 'dd.MM.yyyy HH24:MI:SS') AS
    "CLIPCARD_USAGES.LAST_UPDATED_EXERP"
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
LEFT JOIN
    PERSONS cstaff
ON
    cstaff.center = staff.TRANSFERS_CURRENT_PRS_CENTER
AND cstaff.id = staff.TRANSFERS_CURRENT_PRS_ID
    -- Needed to get PERSON_ID for Agillic
JOIN
    CLIPCARDS cc
ON
    cc.CENTER = cc_usage.CARD_CENTER
AND cc.ID = cc_usage.CARD_ID
AND cc.SUBID = cc_usage.CARD_SUBID
JOIN
    PERSONS p
ON
    p.CENTER = cc.OWNER_CENTER
AND p.ID = cc.OWNER_ID
    -- Needed to get the product ID and make JOINS possible in Agillic
JOIN
    INVOICE_LINES_MT il
ON
    il.CENTER = cc.INVOICELINE_CENTER
AND il.ID = cc.INVOICELINE_ID
AND il.SUBID = cc.INVOICELINE_SUBID
JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                      AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
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
    END                                           AS "PERSON_ID",
    cc.center||'cc'||cc.id||'id'||cc.SUBID                               AS "CLIPCARDS.CLIPCARD_ID",
    il.PRODUCTCENTER||'prod'||il.PRODUCTID                       AS "CLIPCARDS.CLIPCARD_PRODUCT_ID",
    cc.CLIPS_LEFT                                                         AS "CLIPCARDS.CLIPS_LEFT",
    cc.CLIPS_INITIAL                                                   AS "CLIPCARDS.CLIPS_INITIAL",
    cc.INVOICELINE_CENTER||'inv'||cc.INVOICELINE_ID||'ln'||cc.INVOICELINE_SUBID AS
                                                                       "CLIPCARDS.SALES_LINE_ID",
    TO_CHAR(longtodatetz(cc.VALID_FROM,cen.time_zone),'yyyy-MM-dd')  AS "CLIPCARDS.VALID_FROM_DATE",
    TO_CHAR(longtodatetz(cc.VALID_UNTIL,cen.time_zone),'yyyy-MM-dd') AS
    "CLIPCARDS.VALID_UNTIL_DATE",
    CASE
        WHEN cc.BLOCKED = 1
        THEN 'TRUE'
        WHEN cc.BLOCKED = 0
        THEN 'FALSE'
        ELSE 'UNKNOWN'
    END AS "CLIPCARDS.CLIPCARD_BLOCKED",
    CASE
        WHEN cc.CANCELLED = 1
        THEN 'TRUE'
        WHEN cc.CANCELLED = 0
        THEN 'FALSE'
        ELSE 'UNKNOWN'
    END                                                                    AS "CLIPCARDS.CANCELLED",
    TO_CHAR(longtodatetz(cc.CANCELLATION_TIME, cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                          "CLIPCARDS.CANCELLATION_TIME",
    cstaff.external_id                            AS "CLIPCARDS.ASSIGNED_EMPLOYEE_ID",
    CAST( cc.center AS VARCHAR(255))                                       AS "CLIPCARDS.CENTER_ID",
    TO_CHAR(longtodatetz(cc.LAST_MODIFIED , cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
    "CLIPCARDS.LAST_UPDATED_EXERP"
FROM
    CLIPCARDS cc
JOIN
    PERSONS p
ON
    p.center = cc.OWNER_CENTER
AND p.id = cc.OWNER_ID
LEFT JOIN
    persons staff
ON
    staff.center = cc.assigned_staff_center
AND staff.id = cc.assigned_staff_id
LEFT JOIN
    persons cstaff
ON
    cstaff.center = staff.transfers_current_prs_center
AND cstaff.id = staff.transfers_current_prs_id
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
    cen.ID = cc.center
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Only clipcards updated recently
AND cc.LAST_MODIFIED > params.FROM_DATE
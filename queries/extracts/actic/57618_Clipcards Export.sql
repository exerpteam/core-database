-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
    ,
    center_map AS materialized
    (
        SELECT
            c.id AS OldCenterID,
            c.id AS NewCenterID
        FROM
            centers c
        WHERE
            c.id IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,700,
                     730,
                     733,728,762,783,782,737,743,7084,725)
    )
SELECT
    (p.CENTER || 'p' || p.ID)                                        AS PersonId,
    clipcard.CENTER || 'cc' || clipcard.ID || 'id' || clipcard.SUBID AS ClipcardId,
    COALESCE(clip_center_map.NewCenterID,p_center_map.NewCenterID)   AS ClipcardCenterId,
    TO_CHAR(longtodate(clipcard.VALID_UNTIL), 'YYYY-MM-DD')          AS ClipcardExpirationDate,
    pd.GLOBALID                                                      AS OldClipcardTypeId,
    pd.NAME                                                          AS OldClipcardTypeName,
    ROUND(
        CASE
            WHEN il.TOTAL_AMOUNT IS NULL
            THEN pd.PRICE
            ELSE il.TOTAL_AMOUNT/il.QUANTITY
        END,2)          AS ClipcardPrice,
    clipcard.CLIPS_LEFT AS ClipsLeft,
    clipcard.CLIPS_INITIAL,
    pd.GLOBALID AS NewClipcardGlobalId,
    CASE
        WHEN clipcard.assigned_staff_center IS NOT NULL
        THEN assigned_staff_center||'p'||assigned_staff_id
    END AS PersonalTrainerId,
    CASE
        WHEN sales_staff.personcenter IS NOT NULL
        THEN sales_staff.personcenter||'p'||sales_staff.personid
        WHEN staff.personcenter IS NOT NULL
        THEN staff.personcenter||'p'||staff.personid
    END AS SalesPersonId
FROM
    CLIPCARDS clipcard
JOIN
    CLIPCARDTYPES ct
ON
    ct.center = clipcard.CENTER
AND ct.ID = clipcard.ID
JOIN
    PRODUCTS pd
ON
    pd.CENTER = ct.CENTER
AND pd.ID = ct.ID
JOIN
    plist p
ON
    p.CENTER = clipcard.OWNER_CENTER
AND p.ID = clipcard.OWNER_ID
LEFT JOIN
    INVOICELINES il
ON
    clipcard.INVOICELINE_CENTER = il.CENTER
AND clipcard.INVOICELINE_ID = il.ID
AND clipcard.INVOICELINE_SUBID = il.SUBID
LEFT JOIN
    invoices i
ON
    i.center = il.center
AND i.id = il.id
LEFT JOIN
    EMPLOYEES staff
ON
    staff.center = i.EMPLOYEE_CENTER
AND staff.id = i.EMPLOYEE_ID
LEFT JOIN
    invoice_sales_employee ise
ON
    ise.invoice_center = i.center
AND ise.invoice_id = i.id
LEFT JOIN
    EMPLOYEES sales_staff
ON
    sales_staff.center = ise.sales_employee_center
AND sales_staff.id = ise.sales_employee_id
LEFT JOIN
    center_map clip_center_map
ON
    clipcard.center = clip_center_map.OldCenterID
LEFT JOIN
    center_map p_center_map
ON
    p.center = p_center_map.OldCenterID
WHERE
    clipcard.CLIPS_LEFT > 0
AND clipcard.FINISHED = 0
AND clipcard.CANCELLED = 0
AND clipcard.BLOCKED = 0
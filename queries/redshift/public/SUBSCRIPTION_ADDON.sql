SELECT
    sa.ID AS "ID",
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
    END                                              AS "PERSON_ID",
    sa.SUBSCRIPTION_CENTER                           AS "SUBSCRIPTION_CENTER",
    sa.SUBSCRIPTION_CENTER||'ss'||sa.SUBSCRIPTION_ID AS "SUBSCRIPTION_ID",
    prod.center||'prod'||prod.id                     AS "PRODUCT_ID",
    sa.CENTER_ID                                     AS "APPLY_CENTER_ID",
    sa.START_DATE                                    AS "START_DATE",
    sa.END_DATE                                      AS "END_DATE",
    sa.CREATION_TIME                                 AS "CREATION_DATETIME",
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
    END                                                                        AS "CREATOR_PERSON_ID",
    CAST(CAST (sa.CANCELLED AS INT) AS SMALLINT)                               AS "CANCELLED",
    sa.QUANTITY                                                                AS "QUANTITY",
    sa.INDIVIDUAL_PRICE_PER_UNIT                                               AS "INDIVIDUAL_PRICE_PER_UNIT",
    sa.BINDING_END_DATE                                                        AS "BINDING_END_DATE",
    sa.SALES_CENTER_ID                                                         AS "SALE_CENTER_ID",
	CASE 
		WHEN sa.SALES_INTERFACE = 0 THEN 'OTHER'
		WHEN sa.SALES_INTERFACE = 1 THEN 'CLIENT'
		WHEN sa.SALES_INTERFACE = 2 THEN 'WEB'
		WHEN sa.SALES_INTERFACE = 3 THEN 'KIOSK'
		WHEN sa.SALES_INTERFACE = 4 THEN 'SCRIPT'
		WHEN sa.SALES_INTERFACE = 5 THEN 'API'
		WHEN sa.SALES_INTERFACE = 6 THEN 'MOBILE_API'
		WHEN sa.SALES_INTERFACE = 7 THEN 'MOBILE_API_STAFF'
		ELSE 'UNKNOWN'
	END AS "SALE_INTERFACE",
    sa.SUBSCRIPTION_CENTER                                                     AS "CENTER_ID",
    sa.LAST_MODIFIED                                                           AS "ETS"
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    s.center = sa.SUBSCRIPTION_CENTER
    AND s.id = sa.SUBSCRIPTION_ID
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.center = sa.EMPLOYEE_CREATOR_CENTER
    AND emp.id = sa.EMPLOYEE_CREATOR_ID
LEFT JOIN
    PERSONS staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
ON
    prod.center = sa.CENTER_ID
    AND prod.GLOBALID = mpr.GLOBALID
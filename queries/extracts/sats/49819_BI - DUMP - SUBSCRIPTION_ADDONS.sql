SELECT
    cp.EXTERNAL_ID AS PERSON_ID,
    sa.SUBSCRIPTION_CENTER,
    sa.SUBSCRIPTION_ID,
    prod.center||'prod'||prod.id AS ADDON_PRODUCT_ID,
    sa.CENTER_ID,
    TO_CHAR(sa.START_DATE,'yyyy-MM-dd')                              AS START_DATE,
    TO_CHAR(sa.END_DATE,'yyyy-MM-dd')                                AS END_DATE,
    TO_CHAR(longtodateC(sa.CREATION_TIME,sa.CENTER_ID),'yyyy-MM-dd') AS CREATION_DATE,
    cstaff.EXTERNAL_ID                                               AS EMPLOYEE_ID,
    CASE
        WHEN sa.CANCELLED = 0
        THEN 'false'
        WHEN sa.CANCELLED = 1
        THEN 'true'
    END AS CANCELLED,
    sa.QUANTITY,
    sa.INDIVIDUAL_PRICE_PER_UNIT,
    TO_CHAR(sa.BINDING_END_DATE,'yyyy-MM-dd') AS BINDING_END_DATE,
    sa.SALES_CENTER_ID,
    -- BI_DECODE_FIELD('SUBSCRIPTION_ADDON','SALES_INTERFACE',sa.SALES_INTERFACE) as SALES_INTERFACE
    DECODE(sa.SALES_INTERFACE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT',5,'API',6,'MOBILE_API','UNKNOWN') AS SALES_INTERFACE
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
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
JOIN
    EMPLOYEES emp
ON
    emp.center = sa.EMPLOYEE_CREATOR_CENTER
    AND emp.id = sa.EMPLOYEE_CREATOR_ID
JOIN
    PERSONS staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
JOIN
    PERSONS cstaff
ON
    cstaff.center = staff.TRANSFERS_CURRENT_PRS_CENTER
    AND cstaff.id = staff.TRANSFERS_CURRENT_PRS_ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
ON
    prod.center = sa.CENTER_ID
    AND prod.GLOBALID = mpr.GLOBALID
WHERE
    sa.SUBSCRIPTION_CENTER IN ($$Scope$$)
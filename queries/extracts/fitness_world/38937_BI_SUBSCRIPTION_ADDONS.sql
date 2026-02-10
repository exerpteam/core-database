-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    CAST ( sa.ID AS VARCHAR(255))                                    AS "SUBSCRIPTION_ADDON_ID",
    cp.EXTERNAL_ID                                                   AS "PERSON_ID",
    CAST ( sa.SUBSCRIPTION_CENTER AS VARCHAR(255))                   AS "SUBSCRIPTION_CENTER",
    sa.SUBSCRIPTION_CENTER||'ss'||sa.SUBSCRIPTION_ID                 AS "SUBSCRIPTION_ID",
    prod.center||'prod'||prod.id                                     AS "ADDON_PRODUCT_ID",
    sa.CENTER_ID                                                     AS "CENTER_ID",
    TO_CHAR(sa.START_DATE,'yyyy-MM-dd')                              AS "START_DATE",
    TO_CHAR(sa.END_DATE,'yyyy-MM-dd')                                AS "END_DATE",
    TO_CHAR(longtodateC(sa.CREATION_TIME,sa.CENTER_ID),'yyyy-MM-dd') AS "CREATION_DATE",
    cstaff.EXTERNAL_ID                                               AS "EMPLOYEE_ID",
    CASE
        WHEN sa.CANCELLED = 0
        THEN 'false'
        WHEN sa.CANCELLED = 1
        THEN 'true'
    END                                                                        AS "CANCELLED",
    REPLACE(TO_CHAR(sa.QUANTITY,'FM999G999G999G999G999'),',','.') AS "QUANTITY",
    REPLACE(REPLACE(REPLACE(to_char(sa.INDIVIDUAL_PRICE_PER_UNIT , 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')   AS "INDIVIDUAL_PRICE_PER_UNIT",
    TO_CHAR(sa.BINDING_END_DATE,'yyyy-MM-dd')                                  AS "BINDING_END_DATE",
    CAST ( sa.SALES_CENTER_ID AS VARCHAR(255))                                 AS "SALES_CENTER_ID",
    BI_DECODE_FIELD('SUBSCRIPTION_ADDON','SALES_INTERFACE',sa.SALES_INTERFACE) AS "SALES_INTERFACE",
    REPLACE(TO_CHAR(sa.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    PARAMS, SUBSCRIPTION_ADDON sa
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
    sa.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

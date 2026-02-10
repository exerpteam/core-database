-- The extract is extracted from Exerp on 2026-02-08
-- Cut date is latest creation date of addon


SELECT
    s.OWNER_CENTER,
    s.OWNER_ID,
    per.center ||'p'||per.id             AS MemberID,
    per.FIRSTNAME || ' ' || per.LASTNAME AS name,
    addons.name                             addonName,
    addons.start_date                       addonStartDate,
    addons.end_date                         addonEndDate,
    addons.CREATION_date                 AS AddonSaleDate,
    addons.addonPrice,
    --    addons.addonPrice as AddonProductPrice,
    --    addons.INDIVIDUAL_PRICE_PER_UNIT,
    --    nvl(addons.INDIVIDUAL_PRICE_PER_UNIT, addons.addonPrice) as addonPrice,
    CASE
        WHEN addons.EmployeeCenter IS NULL
        THEN ''
        WHEN addons.EmployeeCenter IS NOT NULL
        THEN addons.EmployeeCenter ||'emp'||addons.EmployeeID
    END                  AS AddonSalesStaffID,
    staff.FULLNAME          AddonSalesStaffName,
    p.NAME                  MainSubscription,
    p.PRICE                 MainNormalPrice,
    s.SUBSCRIPTION_PRICE    MainMemberprice,
    s.START_DATE            MainStartDate,
    s.state,
    per.sex      AS gender,
    per.Address1 AS AddressLine1,
    per.address2 AS AddressLine2,
    per.Zipcode,
    per.City,
    per.country
FROM
    SUBSCRIPTIONS s
JOIN
    PRODUCTS p
ON
    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND p.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
JOIN
    PERSONS per
ON
    per.CENTER = s.OWNER_CENTER
    AND per.id = s.OWNER_ID
LEFT JOIN
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            mp.CACHED_PRODUCTNAME AS name,
            addons.START_DATE,
            addons.END_DATE,
            addons.EMPLOYEE_CREATOR_CENTER                            EmployeeCenter,
            addons.EMPLOYEE_CREATOR_ID                                EmployeeID,
            prod.PRICE                                                addonPrice,
            TO_CHAR(longtodate(addons.CREATION_TIME),'yyyy-MM-dd') AS CREATION_date,
            addons.INDIVIDUAL_PRICE_PER_UNIT
        FROM
            SUBSCRIPTION_ADDON addons
        JOIN
            MASTERPRODUCTREGISTER mp
        ON
            mp.ID = addons.ADDON_PRODUCT_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            mp.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN
            PRODUCTS prod
        ON
            prod.GLOBALID = mp.GLOBALID
            AND prod.CENTER = addons.SUBSCRIPTION_CENTER
        JOIN
            SUBSCRIPTIONS s
        ON
            addons.SUBSCRIPTION_CENTER = s.CENTER
            AND addons.SUBSCRIPTION_ID = s.ID
        JOIN
            PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            addons.CENTER_ID IN($$Scope$$)
            AND addons.CANCELLED = 0
            AND addons.CREATION_TIME <= $$CutDate$$
            AND (
                addons.END_DATE IS NULL
                OR addons.END_DATE > longtodate($$CutDate$$) )
        UNION ALL
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            p.NAME,
            s.START_DATE,
            s.END_DATE,
            s.CREATOR_CENTER                                     EmployeeCenter,
            s.CREATOR_ID                                         EmployeeID,
            s.SUBSCRIPTION_PRICE                                 addonPrice,
            TO_CHAR(longtodate(s.CREATION_TIME),'yyyy-MM-dd') AS CREATION_date,
            NULL                                              AS INDIVIDUAL_PRICE_PER_UNIT
        FROM
            SUBSCRIPTIONS s
        JOIN
            PRODUCTS p
        ON
            p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND p.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN
            PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            s.center IN($$Scope$$)
            AND pg.ID IN (9)
            AND s.CREATION_TIME <= $$CutDate$$
            AND (
                s.END_DATE IS NULL
                OR s.END_DATE > longtodate($$CutDate$$)) ) addons
ON
    addons.owner_center = per.center
    AND addons.owner_id = per.id
LEFT JOIN
    EMPLOYEES emp
ON
    addons.EmployeeID = emp.ID
    AND addons.EmployeeCenter = emp.center
LEFT JOIN
    persons staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
WHERE
    s.center IN ( $$Scope$$)
    AND pg.ID NOT IN (1208)
    AND s.START_DATE <= longtodate($$CutDate$$)
    AND (
        s.END_DATE IS NULL
        OR s.END_DATE > longtodate($$CutDate$$) )


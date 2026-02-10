-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    s.OWNER_CENTER,
    s.OWNER_ID,
    per.FIRSTNAME || ' ' || per.LASTNAME name,
    addons.name addonName,
    addons.start_date addonStartDate,
    addons.end_date addonEndDate,
    addons.addonPrice,
    p.NAME MainSubscription,
    p.PRICE MainNormalPrice,
    s.SUBSCRIPTION_PRICE MainMemberprice,
    s.START_DATE MainStartDate,
    s.state,
    per.sex AS gender,
    per.Address1 AS AddressLine1,
    per.address2 AS AddressLine2,
    per.Zipcode,
    per.City,
    per.country,
pea.txtvalue
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
            mp.CACHED_PRODUCTNAME name,
            s.START_DATE,
            s.END_DATE,
            prod.PRICE addonPrice
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
			and prod.CENTER = addons.SUBSCRIPTION_CENTER
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
            addons.CENTER_ID IN(:Scope)
            AND addons.CANCELLED = 0
            AND addons.START_DATE <= :CutDate
            AND (
                addons.END_DATE IS NULL
                OR addons.END_DATE > :CutDate )
        UNION ALL
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            p.NAME,
            s.START_DATE,
            s.END_DATE,
            s.SUBSCRIPTION_PRICE addonPrice
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
            s.center IN(:Scope)
            AND pg.ID IN (9)
            AND s.START_DATE <= :CutDate
            AND (
                s.END_DATE IS NULL
                OR s.END_DATE > :CutDate ) ) addons
ON
    addons.owner_center = per.center
    AND addons.owner_id = per.id
left join PERSON_EXT_ATTRS pea on pea.PERSONCENTER = s.OWNER_CENTER and pea.personID = s.OWNER_ID and pea.name = 'Personal Trainer name'


WHERE
    s.center IN ( :Scope)
    AND pg.ID NOT IN (1208)
    AND s.START_DATE <= :CutDate
    AND (
        s.END_DATE IS NULL
        OR s.END_DATE > :CutDate )

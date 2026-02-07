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
    per.sex as gender,
    per.Address1 as AddressLine1, 
    per.address2 as AddressLine2, 
    per.Zipcode, 
    per.City, 
    per.country
FROM
    PULSE.SUBSCRIPTIONS s
JOIN PULSE.PRODUCTS p
ON
    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND p.ID = s.SUBSCRIPTIONTYPE_ID
JOIN PULSE.PRODUCT_GROUP pg
ON
    p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
JOIN PULSE.PERSONS per
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
            mp.CACHED_PRODUCTPRICE addonPrice
        FROM
            PULSE.SUBSCRIPTION_ADDON addons
        JOIN PULSE.MASTERPRODUCTREGISTER mp
        ON
            mp.ID = addons.ADDON_PRODUCT_ID
        JOIN PULSE.PRODUCT_GROUP pg
        ON
            mp.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN PULSE.SUBSCRIPTIONS s
        ON
            addons.SUBSCRIPTION_CENTER = s.CENTER
            AND addons.SUBSCRIPTION_ID = s.ID
        JOIN PULSE.PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            addons.CENTER_ID = :Scope
            AND addons.CANCELLED = 0
            AND addons.START_DATE <= :CutDate
            AND
            (
                addons.END_DATE IS NULL
                OR addons.END_DATE > :CutDate
            )
        UNION ALL
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            p.NAME,
            s.START_DATE,
            s.END_DATE,
            s.SUBSCRIPTION_PRICE addonPrice
        FROM
            PULSE.SUBSCRIPTIONS s
        JOIN PULSE.PRODUCTS p
        ON
            p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND p.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PULSE.PRODUCT_GROUP pg
        ON
            p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN PULSE.PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            s.center = :Scope
            AND pg.ID IN (1208)
            AND s.START_DATE <= :CutDate
            AND
            (
                s.END_DATE IS NULL
                OR s.END_DATE > :CutDate
            )
    )
    addons
ON
    addons.owner_center = per.center
    AND addons.owner_id = per.id
WHERE
    s.center = :Scope
    AND pg.ID NOT IN (1208)
    AND s.START_DATE <= :CutDate
    AND
    (
        s.END_DATE IS NULL
        OR s.END_DATE > :CutDate
    )

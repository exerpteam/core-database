SELECT
    SUM(NVL(expected_revenue_addon,0)) + MAX(expected_revenue) revenue,
    NAME,
    FIRSTNAME,
    LASTNAME,
    BINDING_END_DATE,
    PersonType,
    center,
    id
FROM
    (
        SELECT
            s.CENTER,
            s.id,
            p.FIRSTNAME,
            p.LASTNAME,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
            prod.NAME,
            s.BINDING_END_DATE,
            ROUND(months_between(s.BINDING_END_DATE+1,greatest(sysdate,TRUNC(ADD_MONTHS(s.START_DATE,1),'MONTH'))) * s.BINDING_PRICE ,2) expected_revenue,
            ROUND(months_between(s.BINDING_END_DATE+1,greatest(sysdate,TRUNC(ADD_MONTHS(sa.START_DATE,1),'MONTH'))) * mpr.CACHED_PRODUCTPRICE ,2) expected_revenue_addon
        FROM
            SUBSCRIPTIONS s
        JOIN PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = s.CENTER
            AND sa.SUBSCRIPTION_ID = s.ID
            AND sa.CANCELLED = 0
        LEFT JOIN MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
        WHERE
            s.BINDING_END_DATE > sysdate
            AND s.STATE IN (2,4,8)
            and s.CREATION_TIME between :createdFrom and :createdTo
    )
GROUP BY
    center,
    id,
    name,
    FIRSTNAME,
    LASTNAME,
    BINDING_END_DATE,
    PersonType
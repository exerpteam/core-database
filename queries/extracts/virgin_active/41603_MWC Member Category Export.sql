SELECT
    a.*,
    c.FACILITY_URL
FROM
    (
        SELECT
            EXTERNAL_ID AS PERSON_ID,
            CASE
                WHEN MAX(cat) = 1
                THEN 'Life'
                WHEN MAX(cat) = 2
                THEN 'Premium'
                WHEN MAX(cat) = 3
                THEN 'Premium Plus'
                WHEN MAX(cat) = 4
                THEN 'Collection'
            END AS CATEGORY
        FROM
            (
                SELECT DISTINCT
                    sasp.EXTERNAL_ID,
                    CASE
                        WHEN psi.CHILD_ID IN(51656) -- Life*
                        THEN 1
                        WHEN psi.CHILD_ID IN(51657) -- Premium *
                        THEN 2
                        WHEN psi.CHILD_ID IN(51655) -- Premium Plus*
                        THEN 3
                        WHEN psi.CHILD_ID IN(51654) -- Collection*
                        THEN 4
                    END                      AS cat,
                    sampr.CACHED_PRODUCTNAME AS PRODUCT_NAME
                FROM
                    VA.PRIVILEGE_GRANTS pg
                JOIN
                    VA.MASTERPRODUCTREGISTER sampr
                ON
                    sampr.id = pg.GRANTER_ID
                    AND pg.GRANTER_SERVICE = 'Addon'
                JOIN
                    VA.SUBSCRIPTION_ADDON sa
                ON
                    sa.ADDON_PRODUCT_ID = sampr.id
                    AND sa.CANCELLED = 0
                    AND(
                        sa.END_DATE IS NULL
                        OR sa.END_DATE > SYSDATE)
                JOIN
                    VA.SUBSCRIPTIONS sas
                ON
                    sas.center = sa.SUBSCRIPTION_CENTER
                    AND sas.id = sa.SUBSCRIPTION_ID
                JOIN
                    VA.PERSONS sasp
                ON
                    sasp.center = sas.OWNER_CENTER
                    AND sasp.id = sas.OWNER_ID
                JOIN
                    VA.PRIVILEGE_SET_INCLUDES psi
                ON
                    psi.PARENT_ID = pg.PRIVILEGE_SET
                WHERE
                    pg.VALID_TO IS NULL
                    AND psi.VALID_TO IS NULL
                    AND psi.CHILD_ID IN (51654,51657,51655,51656)
                UNION ALL
                SELECT DISTINCT
                    p.EXTERNAL_ID,
                    CASE
                        WHEN psi.CHILD_ID IN(51656) -- Life*
                        THEN 1
                        WHEN psi.CHILD_ID IN(51657) -- Premium *
                        THEN 2
                        WHEN psi.CHILD_ID IN(51655) -- Premium Plus*
                        THEN 3
                        WHEN psi.CHILD_ID IN(51654) -- Collection*
                        THEN 4
                    END      AS cat,
                    spr.NAME AS PRODUCT_NAME
                FROM
                    VA.PRIVILEGE_GRANTS pg
                JOIN
                    VA.MASTERPRODUCTREGISTER smpr
                ON
                    smpr.id = pg.GRANTER_ID
                    AND pg.GRANTER_SERVICE = 'GlobalSubscription'
                JOIN
                    VA.PRODUCTS spr
                ON
                    spr.GLOBALID = smpr.GLOBALID
                JOIN
                    VA.SUBSCRIPTIONS s
                ON
                    s.SUBSCRIPTIONTYPE_CENTER = spr.center
                    AND s.SUBSCRIPTIONTYPE_ID = spr.id
                    AND s.STATE IN (2,4)
                JOIN
                    VA.PERSONS p
                ON
                    p.center = s.OWNER_CENTER
                    AND p.id = s.OWNER_ID
                JOIN
                    VA.PRIVILEGE_SET_INCLUDES psi
                ON
                    psi.PARENT_ID = pg.PRIVILEGE_SET
                WHERE
                    pg.VALID_TO IS NULL
                    AND psi.VALID_TO IS NULL
                    AND psi.CHILD_ID IN (51654,51657,51655,51656)
                    AND s.center IN ($$scope$$))
        GROUP BY
            EXTERNAL_ID) a
JOIN
    VA.PERSONS p
ON
    p.EXTERNAL_ID = a.PERSON_ID
JOIN
    VA.CENTERS c
ON
    c.id = p.CURRENT_PERSON_CENTER


-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2098
WITH
    invl_usage AS
    (
        SELECT
            pu.*,
            prod.name AS product_name
        FROM
            invoices inv
        JOIN
            puregym.invoice_lines_mt invl
        ON
            invl.center = inv.center
        AND invl.id = inv.id
        JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.target_center = invl.center
        AND pu.target_id = invl.id
        AND pu.target_subid = invl.subid
        AND pu.TARGET_SERVICE = 'InvoiceLine'
        JOIN
            PRODUCTS prod
        ON
            invl.PRODUCTID = prod.ID
        AND invl.PRODUCTCENTER = prod.CENTER
        WHERE
            inv.entry_time BETWEEN :longDateFrom AND :longDateTo + 1000*60*60*24
        AND invl.person_center IN (:scope)
    )
    ,
    sp_usage AS
    (
        SELECT
            pu.*,
            prod2.name AS product_name,
            CASE
                WHEN s.center IS NOT NULL
                THEN s.CENTER || 'ss' || s.ID
                ELSE NULL
            END AS subscription_id
        FROM
            SUBSCRIPTION_PRICE sp
        JOIN
            PRIVILEGE_USAGES pu
        ON
            sp.ID = pu.TARGET_ID
        AND pu.TARGET_SERVICE = 'SubscriptionPrice'
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sp.SUBSCRIPTION_CENTER
        AND s.ID = sp.SUBSCRIPTION_ID
        LEFT JOIN
            PRODUCTS prod2
        ON
            s.SUBSCRIPTIONTYPE_ID = prod2.ID
        AND s.SUBSCRIPTIONTYPE_CENTER = prod2.CENTER
        WHERE
            sp.entry_time BETWEEN :longDateFrom AND :longDateTo + 1000*60*60*24
        AND s.owner_center IN (:scope)
    )
    ,
    v_usages AS
    (
        SELECT
            *,
            NULL AS subscription_id
        FROM
            invl_usage
        UNION ALL
        SELECT
            *
        FROM
            sp_usage
    )
SELECT
    cen.NAME                                                                  AS "Center name",
    sc.name                                                                   AS "Campaign Name",
    cc.code                                                              AS "Code",
    priset.NAME                                                             AS "Privilege Set Name",
    pu.product_name                                                           AS "Name",
    currentP.EXTERNAL_ID::INT                                                 AS "External Id",
    p.CENTER || 'p' || p.ID                                                   AS "Member Id",
    TO_CHAR(longtodateC(pu.USE_TIME,currentP.center),'YYYY-MM-DD HH24:MI:SS') AS "Date Code Used",
pu.subscription_id as "Subscription Id"
FROM
    v_usages pu
JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.id = cc.CAMPAIGN_ID
AND cc.CAMPAIGN_TYPE ='STARTUP'
AND sc.PLUGIN_CODES_NAME = :pluginCodeName
JOIN
    PRIVILEGE_GRANTS pgra
ON
    pgra.ID = pu.GRANT_ID
JOIN
    PRIVILEGE_SETS priset
ON
    priset.ID = pgra.PRIVILEGE_SET
JOIN
    PERSONS p
ON
    p.CENTER=pu.PERSON_CENTER
AND p.ID=pu.PERSON_ID
JOIN
    PERSONS currentP
ON
    currentP.CENTER = p.CURRENT_PERSON_CENTER
AND currentP.ID = p.CURRENT_PERSON_ID
JOIN
    CENTERS cen
ON
    cen.ID = currentP.CENTER
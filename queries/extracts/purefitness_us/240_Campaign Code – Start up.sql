-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8560
/*
  pluginCodeName: 'GENERATED' : Single Use Code , UNIQUE: Multi Use Code
*/

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST(dateToLongC(TO_CHAR(CAST($$From_Date$$ AS DATE),'YYYY-MM-DD') || ' 00:00', c.id) AS BIGINT)                from_date ,
            CAST(dateToLongC(TO_CHAR(CAST($$To_Date$$ AS DATE),'YYYY-MM-DD') || ' 00:00', c.id) AS BIGINT)+ 1000*60*60*24 to_date
        FROM
            centers c
    )
SELECT
    cen.NAME            AS "Center name",
    t1.CampaignName     AS "Campaign Name",
    t1.Code             AS "Code",
    t1.PrivilegeSetName AS "Privilege Set Name",
    t1.Name             AS "Name",
    (
        CASE
            WHEN t1.ExternalId IS NULL
            THEN currentP.EXTERNAL_ID
            ELSE t1.ExternalId
        END)                                                                  AS "External Id",
    t1.MemberId                                                               AS "Member Id",
    TO_CHAR(longtodateC(t1.UseTime,t1.CurrentCenter),'YYYY-MM-DD HH24:MI:SS') AS "Date Code Used",
    (
        CASE
            WHEN t1.SubscriptionId='ss'
            THEN NULL
            ELSE t1.SubscriptionId
        END) AS "Subscription Id"
FROM
    (
        SELECT
            sc.NAME     AS CampaignName,
            cc.CODE     AS Code,
            priset.NAME AS PrivilegeSetName,
            (
                CASE
                    WHEN prod.NAME IS NULL
                    THEN prod2.NAME
                    ELSE prod.NAME
                END)                 AS Name,
            p.EXTERNAL_ID            AS ExternalId,
            p.CENTER || 'p' || p.ID  AS MemberId,
            pu.USE_TIME              AS UseTime,
            p.CURRENT_PERSON_CENTER  AS CurrentCenter,
            p.CURRENT_PERSON_ID      AS CurrentId,
            s.CENTER || 'ss' || s.ID AS SubscriptionId
        FROM
            CAMPAIGN_CODES cc
        JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.id = cc.CAMPAIGN_ID
            AND cc.CAMPAIGN_TYPE ='STARTUP'
        LEFT JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.CAMPAIGN_CODE_ID = cc.ID
            AND pu.TARGET_SERVICE IN ('InvoiceLine',
                                      'SubscriptionPrice')
            AND pu.PRIVILEGE_TYPE = 'PRODUCT'
        LEFT JOIN
            PRIVILEGE_GRANTS pgra
        ON
            pgra.ID = pu.GRANT_ID
        LEFT JOIN
            PRIVILEGE_SETS priset
        ON
            priset.ID = pgra.PRIVILEGE_SET
        LEFT JOIN
            invoice_lines_mt invl
        ON
            invl.CENTER = pu.TARGET_CENTER
            AND invl.ID = pu.TARGET_ID
            AND invl.SUBID = pu.TARGET_SUBID
        LEFT JOIN
            PRODUCTS prod
        ON
            invl.PRODUCTID = prod.ID
            AND invl.PRODUCTCENTER = prod.CENTER
        LEFT JOIN
            INVOICES inv
        ON
            inv.CENTER = invl.CENTER
            AND inv.ID = invl.ID
        LEFT JOIN
            SUBSCRIPTION_PRICE sp
        ON
            sp.ID = pu.TARGET_ID
            AND pu.TARGET_SERVICE = 'SubscriptionPrice'
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sp.SUBSCRIPTION_CENTER
            AND s.ID = sp.SUBSCRIPTION_ID
        LEFT JOIN
            PRODUCTS prod2
        ON
            s.SUBSCRIPTIONTYPE_ID = prod2.ID
            AND s.SUBSCRIPTIONTYPE_CENTER = prod2.CENTER
        JOIN
            PERSONS p
        ON
            p.CENTER=pu.PERSON_CENTER
            AND p.ID=pu.PERSON_ID
        JOIN
            params
        ON
            params.id = p.center
        WHERE
            pu.USE_TIME BETWEEN params.from_date AND params.to_date
            AND sc.PLUGIN_CODES_NAME = ($$pluginCodeName$$)
            AND p.CENTER IN ($$Scope$$) ) t1
JOIN
    PERSONS currentP
ON
    currentP.CENTER = t1.CurrentCenter
    AND currentP.ID = t1.CurrentId
JOIN
    CENTERS cen
ON
    cen.ID = currentP.CENTER
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
    t1.Center           AS "Center",
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
    t1.StartDateTrial                                                         AS "Start Date Trial",
    t1.EndDateTrial                                                           AS "End Date Trial",
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
            cen.Name                AS Center,
            prg.NAME                AS CampaignName,
            cc.CODE                 AS Code,
            priset.NAME             AS PrivilegeSetName,
            prod.NAME               AS Name,
            p.EXTERNAL_ID           AS ExternalId,
            p.CENTER || 'p' || p.ID AS MemberId,
            (
                CASE
                    WHEN LOWER(prod.NAME) LIKE '%day pass%'
                    THEN s.START_DATE
                    ELSE NULL
                END) AS StartDateTrial,
            (
                CASE
                    WHEN LOWER(prod.NAME) LIKE '%day pass%'
                    THEN s.END_DATE
                    ELSE NULL
                END)                 AS EndDateTrial,
            pu.USE_TIME              AS UseTime,
            p.CURRENT_PERSON_CENTER  AS CurrentCenter,
            p.CURRENT_PERSON_ID      AS CurrentId,
            s.CENTER || 'ss' || s.ID AS SubscriptionId
        FROM
            INVOICES inv
        JOIN
            persons p
        ON
            p.CENTER = inv.PAYER_CENTER
            AND p.ID = inv.PAYER_ID
        JOIN
            params
        ON
            params.id = p.center
        JOIN
            invoice_lines_mt invl
        ON
            inv.CENTER = invl.CENTER
            AND inv.ID = invl.ID
        JOIN
            PRODUCTS prod
        ON
            invl.PRODUCTID = prod.ID
            AND invl.PRODUCTCENTER = prod.CENTER
        JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.TARGET_SERVICE = 'InvoiceLine'
            AND pu.PRIVILEGE_TYPE = 'PRODUCT'
            AND pu.TARGET_CENTER = invl.CENTER
            AND pu.TARGET_ID = invl.ID
            AND pu.TARGET_SUBID = invl.SUBID
        JOIN
            CAMPAIGN_CODES cc
        ON
            pu.CAMPAIGN_CODE_ID = cc.ID
            AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
        JOIN
            PRIVILEGE_RECEIVER_GROUPS prg
        ON
            prg.ID = cc.CAMPAIGN_ID
        LEFT JOIN
            CENTERS cen
        ON
            cen. ID = P.CENTER
        LEFT JOIN
            PRIVILEGE_GRANTS pgra
        ON
            pgra.ID = pu.GRANT_ID
        LEFT JOIN
            PRIVILEGE_SETS priset
        ON
            priset.ID = pgra.PRIVILEGE_SET
        LEFT JOIN
            SPP_INVOICELINES_LINK sil
        ON
            sil.INVOICELINE_CENTER = invl.CENTER
            AND sil.INVOICELINE_ID = invl.ID
            AND sil.INVOICELINE_SUBID = invl.SUBID
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sil.PERIOD_CENTER
            AND s.ID = sil.PERIOD_ID
        WHERE
            inv.TRANS_TIME BETWEEN params.from_date AND params.to_date
            AND prg.PLUGIN_CODES_NAME = ($$pluginCodeName$$)
            AND p.CENTER IN ($$Scope$$) ) t1
JOIN
    PERSONS currentP
ON
    currentP.CENTER = t1.CurrentCenter
    AND currentP.ID = t1.CurrentId
-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS
(
  SELECT
    CAST(:longDateFrom AS BIGINT) AS DateFrom,
    CAST((:longDateTo + 86400000) AS BIGINT) AS DateTo
    
)
 SELECT
    t1.Center AS "Center",
    t1.CampaignName AS "Campaign Name",
    t1.Code AS "Code",
    t1.PrivilegeSetName AS "Privilege Set Name",
    t1.Name AS "Name",
    (CASE
       WHEN t1.ExternalId IS NULL THEN
           currentP.EXTERNAL_ID::bigint
       ELSE
           t1.ExternalId::bigint
    END) AS "External Id",
    t1.MemberId AS "Member Id",
    t1.StartDateTrial AS "Start Date Trial",
    t1.EndDateTrial AS "End Date Trial",
    to_char(longtodateTZ(t1.UseTime,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') as "Date Code Used",
    (CASE
         WHEN t1.SubscriptionId='ss' THEN
                 NULL
         ELSE
                 t1.SubscriptionId
     END) AS "Subscription Id"
 FROM
 (
         SELECT
         cen.Name AS Center,
         prg.NAME AS CampaignName,
         cc.CODE AS Code,
         priset.NAME AS PrivilegeSetName,
         prod.NAME AS Name,
         p.EXTERNAL_ID AS ExternalId,
         p.CENTER || 'p' || p.ID AS MemberId,
         (CASE
             WHEN lower(prod.NAME) LIKE '%day pass%' THEN
                 s.START_DATE
             ELSE
                 NULL
         END) AS StartDateTrial,
         (CASE
             WHEN lower(prod.NAME) LIKE '%day pass%' THEN
                 s.END_DATE
             ELSE
                 NULL
         END) AS EndDateTrial,
         pu.USE_TIME as UseTime,
         p.CURRENT_PERSON_CENTER AS CurrentCenter,
         p.CURRENT_PERSON_ID AS CurrentId,
         s.CENTER || 'ss' || s.ID AS SubscriptionId
         FROM
         PARAMS,
         INVOICES inv
         JOIN
         PERSONS p
         ON
         p.CENTER = inv.PAYER_CENTER
         AND p.ID = inv.PAYER_ID
         JOIN
         INVOICELINES invl
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
         inv.TRANS_TIME BETWEEN params.DateFrom AND params.DateTo 
         AND prg.PLUGIN_CODES_NAME = :pluginCodeName
         AND p.CENTER IN (:scope)
     ) t1
 JOIN
         PERSONS currentP
 ON
     currentP.CENTER = t1.CurrentCenter
     AND currentP.ID = t1.CurrentId
 --WHERE
         --currentP.CENTER NOT IN (101,177)

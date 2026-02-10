-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
    cen.Name AS "Center",
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
    to_char(longtodate(t1.UseTime),'YYYY-MM-DD HH24:MI:SS') as "Date Code Used",
    (CASE
         WHEN t1.SubscriptionId='ss' THEN
                 NULL
         ELSE
                 t1.SubscriptionId
     END) AS "Subscription Id"
 FROM
 (
         SELECT
                 p.CURRENT_PERSON_CENTER AS CurrentCenter,
                 p.CURRENT_PERSON_ID AS CurrentId,
                 s.CENTER || 'ss' || s.ID AS SubscriptionId,
                 pu.USE_TIME as UseTime,
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
                 p.CENTER || 'p' || p.ID AS MemberId,
                 p.EXTERNAL_ID AS ExternalId,
                 prod.NAME AS Name,
                 priset.NAME AS PrivilegeSetName,
                 cc.CODE AS Code,
                 prg.NAME AS CampaignName
         FROM CAMPAIGN_CODES cc
         JOIN PRIVILEGE_USAGES pu ON pu.CAMPAIGN_CODE_ID = cc.ID AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice') AND pu.PRIVILEGE_TYPE = 'PRODUCT'
         LEFT JOIN PRIVILEGE_GRANTS pgra ON pgra.ID = pu.GRANT_ID
         LEFT JOIN PRIVILEGE_SETS priset ON priset.ID = pgra.PRIVILEGE_SET
         LEFT JOIN STARTUP_CAMPAIGN sc ON sc.id = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE ='STARTUP'
         LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
         LEFT JOIN INVOICELINES invl ON invl.CENTER = pu.TARGET_CENTER AND invl.ID = pu.TARGET_ID AND invl.SUBID = pu.TARGET_SUBID
         LEFT JOIN INVOICES inv ON inv.CENTER = invl.CENTER AND inv.ID = invl.ID
         JOIN SPP_INVOICELINES_LINK sil ON sil.INVOICELINE_CENTER = invl.CENTER AND sil.INVOICELINE_ID = invl.ID AND sil.INVOICELINE_SUBID = invl.SUBID
         LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sil.PERIOD_CENTER AND s.ID = sil.PERIOD_ID
         JOIN PRODUCTS prod ON invl.PRODUCTID = prod.ID  AND invl.PRODUCTCENTER = prod.CENTER
         JOIN PERSONS p  ON p.CENTER = inv.PAYER_CENTER AND p.ID = inv.PAYER_ID
         --LEFT JOIN SUBSCRIPTION_PRICE sp ON sp.ID = pu.TARGET_ID AND pu.TARGET_SERVICE = 'SubscriptionPrice'
         --LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
         WHERE
               pu.USE_TIME BETWEEN :longDateFrom AND :longDateTo
               AND (prg.PLUGIN_CODES_NAME = :pluginCodeName OR sc.PLUGIN_CODES_NAME = :pluginCodeName)
               AND p.CENTER IN (:scope)
 ) t1
 JOIN
         PERSONS currentP
 ON
     currentP.CENTER = t1.CurrentCenter
     AND currentP.ID = t1.CurrentId
 JOIN CENTERS cen ON cen.ID = currentP.CENTER

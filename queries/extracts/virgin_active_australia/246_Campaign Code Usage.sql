-- This is the version from 2026-02-05
--  
 SELECT
         cen.Name AS CENTER,
         table1.CampaignName,
         table1.Code,
         table1.PrivilegeSetName,
         COUNT(table1.Code) AS uses
 FROM
         (SELECT
                 COALESCE(s.OWNER_CENTER, inv.PAYER_CENTER) AS CENTER,
                 COALESCE(prg.NAME,sc.NAME) AS CampaignName,
                 cc.CODE AS Code,
                 priset.NAME AS PrivilegeSetName
         FROM CAMPAIGN_CODES cc
         JOIN PRIVILEGE_USAGES pu ON pu.CAMPAIGN_CODE_ID = cc.ID AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice') AND pu.PRIVILEGE_TYPE = 'PRODUCT'
         LEFT JOIN PRIVILEGE_GRANTS pgra ON pgra.ID = pu.GRANT_ID
         LEFT JOIN PRIVILEGE_SETS priset ON priset.ID = pgra.PRIVILEGE_SET
         LEFT JOIN STARTUP_CAMPAIGN sc ON sc.id = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE ='STARTUP'
         LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
         LEFT JOIN INVOICELINES invl ON invl.CENTER = pu.TARGET_CENTER AND invl.ID = pu.TARGET_ID AND invl.SUBID = pu.TARGET_SUBID
         LEFT JOIN INVOICES inv ON inv.CENTER = invl.CENTER AND inv.ID = invl.ID
         LEFT JOIN SUBSCRIPTION_PRICE sp ON sp.ID = pu.TARGET_ID AND pu.TARGET_SERVICE = 'SubscriptionPrice'
         LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
                 WHERE
                 pu.USE_TIME BETWEEN :longDateFrom AND :longDateTo + (1000*60*60*24)
                 AND (
                         prg.PLUGIN_CODES_NAME = :pluginCodeName
                         OR sc.PLUGIN_CODES_NAME = :pluginCodeName)
                 ) table1
 LEFT JOIN CENTERS cen ON cen.ID = table1.CENTER
 WHERE table1.CENTER IN (:scope)
 GROUP BY
     cen.Name,
     table1.CampaignName,
     table1.code,
     table1.PrivilegeSetName

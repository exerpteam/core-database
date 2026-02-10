-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         cen.Name AS club,
                 table1.FULLNAME AS nominativo,
         table1.CampaignName as campagna,
         table1.Code as codice,
         table1.dataUtilizzo,
         CASE WHEN table1.TEXT IS NOT NULL THEN table1.TEXT ELSE
                 table1.CREATION end AS Prodotto,
                 table1.importo
 FROM
         (SELECT
                 COALESCE(s.OWNER_CENTER, inv.PAYER_CENTER) AS CENTER,
                 COALESCE(prg.NAME,sc.NAME) AS CampaignName,
                 cc.CODE AS Code,
                 priset.NAME AS PrivilegeSetName,
                                 p.FULLNAME,
                                 LongToDate(pu.USE_TIME) as dataUtilizzo,
                                 invl.TOTAL_AMOUNT as importo,
                 invl.TEXT,
                                 invl1.TEXT as CREATION,
                                 pu.TARGET_SERVICE
         FROM CAMPAIGN_CODES cc
         JOIN PRIVILEGE_USAGES pu ON pu.CAMPAIGN_CODE_ID = cc.ID AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice') AND pu.PRIVILEGE_TYPE = 'PRODUCT'
                 JOIN PERSONS p
         ON
                         p.ID = pu.PERSON_ID
                 AND
                         p.CENTER = pu.PERSON_CENTER
         LEFT JOIN PRIVILEGE_GRANTS pgra ON pgra.ID = pu.GRANT_ID
         LEFT JOIN PRIVILEGE_SETS priset ON priset.ID = pgra.PRIVILEGE_SET
         LEFT JOIN STARTUP_CAMPAIGN sc ON sc.id = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE ='STARTUP'
         LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
         LEFT JOIN INVOICELINES invl ON invl.CENTER = pu.TARGET_CENTER AND invl.ID = pu.TARGET_ID AND invl.SUBID = pu.TARGET_SUBID
         LEFT JOIN INVOICES inv ON inv.CENTER = invl.CENTER AND inv.ID = invl.ID
         LEFT JOIN SUBSCRIPTION_PRICE sp ON sp.ID = pu.TARGET_ID AND pu.TARGET_SERVICE = 'SubscriptionPrice'
         LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
 LEFT JOIN INVOICELINES invl1 ON invl1.CENTER = s.INVOICELINE_CENTER AND invl1.ID = s.INVOICELINE_ID AND invl1.SUBID = s.INVOICELINE_SUBID
                 WHERE
                 pu.USE_TIME BETWEEN :longDateFrom AND :longDateTo + (1000*60*60*24)
                  ) table1
 LEFT JOIN CENTERS cen ON cen.ID = table1.CENTER
 WHERE table1.CENTER IN (:scope)
 AND
 (
 table1.CODE LIKE 'S159%'
 OR
 table1.CODE LIKE 'S495%'
 OR
 table1.CODE LIKE 'S795%'
 OR
 table1.CODE LIKE 'S99%'
 )
 ORDER BY
     cen.Name,
     table1.CampaignName,
     table1.FULLNAME,
      CASE WHEN table1.TEXT IS NOT NULL THEN table1.TEXT ELSE
                 table1.CREATION end

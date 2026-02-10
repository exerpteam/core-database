-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
    cen.NAME AS CENTER,
    table1.*
 FROM
         (SELECT
                         COALESCE(p.CENTER, inv.PAYER_CENTER) AS PERSONCENTER,
             p.FULLNAME,
             COALESCE(p.CENTER,inv.PAYER_CENTER) || 'p' || COALESCE(p.ID,inv.PAYER_ID) AS Pref,
             p.ADDRESS1,
             p.ADDRESS2,
             p.ADDRESS3,
             p.ZIPCODE,
             longToDate(pu.USE_TIME) AS used_time,
             longToDate(cc.CREATION_TIME)                            codes_created,
             COALESCE(longToDate(prg.STARTTIME),longtodate(sc.STARTTIME)) campaign_start_time,
             COALESCE(prod.NAME,prod2.NAME) AS NAME,
             invl.TOTAL_AMOUNT,
             COALESCE(prg.NAME,sc.NAME) AS "Campaign",
             prg.NAME as "PRG",
             sc.NAME as "SC",
                         s.START_DATE,
                         s.BINDING_END_DATE
         FROM
             CAMPAIGN_CODES cc
         JOIN PRIVILEGE_USAGES pu
         ON
             pu.CAMPAIGN_CODE_ID = cc.ID
             AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice')
             AND pu.PRIVILEGE_TYPE = 'PRODUCT'
         LEFT JOIN INVOICELINES invl
         ON
             invl.CENTER = pu.TARGET_CENTER
             AND invl.ID = pu.TARGET_ID
             AND invl.SUBID = pu.TARGET_SUBID
         LEFT JOIN INVOICES inv
         ON
             inv.CENTER = invl.CENTER
             AND inv.ID = invl.ID
         LEFT JOIN CREDIT_NOTE_LINES cnl
         ON
             cnl.INVOICELINE_CENTER = invl.CENTER
             AND cnl.INVOICELINE_ID = invl.ID
             AND cnl.INVOICELINE_SUBID = invl.SUBID
         LEFT JOIN PRODUCTS prod
         ON
             prod.CENTER = invl.PRODUCTCENTER
             AND prod.ID = invl.PRODUCTID
         LEFT JOIN PRODUCT_GROUP pg
         ON
             pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
         LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg
         ON
             cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
             AND prg.ID = cc.CAMPAIGN_ID
         LEFT JOIN STARTUP_CAMPAIGN sc
         ON
             cc.CAMPAIGN_TYPE = 'STARTUP'
             AND sc.ID = cc.CAMPAIGN_ID
         LEFT JOIN SUBSCRIPTION_PRICE sp
         ON
             sp.ID = pu.TARGET_ID
             AND pu.TARGET_SERVICE = 'SubscriptionPrice'
         LEFT JOIN SUBSCRIPTIONS s
         ON
             s.CENTER = sp.SUBSCRIPTION_CENTER
             AND s.ID = sp.SUBSCRIPTION_ID
         LEFT JOIN PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
         LEFT JOIN SUBSCRIPTIONTYPES st
         ON
             s.SUBSCRIPTIONTYPE_CENTER=st.CENTER
             AND s.SUBSCRIPTIONTYPE_ID=st.ID
         LEFT JOIN PRODUCTS prod2
         ON
             st.CENTER=prod2.CENTER and st.ID=prod2.ID
         WHERE
             (
             pu.USE_TIME BETWEEN :longDateFrom AND :longDateTo + (1000*60*60*24)
             AND cc.CODE = :code
             )) table1
         LEFT JOIN CENTERS cen
     ON
        cen.ID = table1.PERSONCENTER
 WHERE PERSONCENTER IN (:scope)

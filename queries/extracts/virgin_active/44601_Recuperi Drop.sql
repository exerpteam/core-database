 SELECT
     c.SHORTNAME                                         AS "CLUB",
     ss.SALES_DATE                                                               AS "SALES DATE",
         longtodateC(scStop.STOP_CHANGE_TIME, s_old.CENTER)  AS  "CANCELLATION_DATE",
     p.CENTER || 'p' || p.ID                             AS "PERSON ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 
          'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS  "STATUS PERSON",
     s_new.CENTER||'ss'||s_new.ID                        AS "SUB ID",
     p.FULLNAME                                          AS "FULL NAME",
     prod_new.NAME                                       AS "SUBSCRIPTION",
     pg.NAME                                             AS "PRODUCT GROUP",
     CASE  s_new.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS  "STATUS NEW SUB",
     CASE  s_new.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 
         'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS  "SUBSTATUS NEW SUB",
     s_new.START_DATE                                                        AS "START DATE NEW SUB",
     s_new.END_DATE                                                              AS "STOP DATE NEW SUB",
     s_new.BINDING_END_DATE                                                      AS "BINDING DATE NEW SUB",
     prod_old.NAME                                       AS "EXTENDED FROM",
     CASE  s_old.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS  "STATUS OLD SUB",
     CASE  s_old.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 
         'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS  "SUBSTATUS OLD SUB",
     s_old.START_DATE                                                        AS "START DATE OLD SUB",
     s_old.END_DATE                                                              AS "STOP DATE OLD SUB",
     sales_person.FULLNAME                               AS "SALES PERSON",
     ss.PRICE_NEW                                        AS "AF",
     cc_startup.CODE || ' ' || cc.CODE                   AS "CAMPAIGN CODE"
 FROM
     SUBSCRIPTION_SALES ss
 JOIN
     SUBSCRIPTIONS s_new
 ON
     ss.SUBSCRIPTION_CENTER = s_new.CENTER
     AND ss.SUBSCRIPTION_ID = s_new.ID
 JOIN
    CENTERS c
 ON
    c.ID = s_new.CENTER
    AND c.COUNTRY = 'IT'
 JOIN
    PERSONS p
 ON
    s_new.OWNER_CENTER = p.CENTER
    AND s_new.OWNER_ID = p.ID
 JOIN
    PRODUCTS prod_new
 ON
    prod_new.CENTER = s_new.SUBSCRIPTIONTYPE_CENTER
    AND prod_new.ID = s_new.SUBSCRIPTIONTYPE_ID
 JOIN
    PRODUCT_GROUP pg
 ON
    pg.ID = prod_new.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     SUBSCRIPTION_CHANGE sc
 ON
     sc.NEW_SUBSCRIPTION_CENTER = s_new.center
     AND sc.NEW_SUBSCRIPTION_ID = s_new.id
     AND sc.TYPE = 'EXTENSION'
 JOIN
     SUBSCRIPTIONS s_old
 ON
     s_old.center = sc.OLD_SUBSCRIPTION_CENTER
     AND s_old.id = sc.OLD_SUBSCRIPTION_ID
 JOIN
     PRODUCTS prod_old
 ON
     prod_old.CENTER = s_old.SUBSCRIPTIONTYPE_CENTER
     AND prod_old.ID = s_old.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PERSON_EXT_ATTRS mc
 ON
    p.center = mc.PERSONCENTER
    AND p.id = mc.PERSONID
    AND mc.name = 'MC_IT'
 LEFT JOIN
    PERSONS sales_person
 ON
    sales_person.center||'p'||sales_person.id = mc.TXTVALUE
 LEFT JOIN
     INVOICE_LINES_MT il
 ON
     il.center = s_new.invoiceline_center
     AND il.id = s_new.invoiceline_id
     AND il.subid = s_new.invoiceline_subid
 LEFT JOIN
     CAMPAIGN_CODES cc_startup
 ON
     s_new.CAMPAIGN_CODE_ID = cc_startup.ID
 LEFT JOIN
     PRIVILEGE_USAGES pu
 ON
     pu.CAMPAIGN_CODE_ID is not null
     AND pu.TARGET_SERVICE = 'InvoiceLine'
     AND pu.TARGET_CENTER = il.center
     AND pu.TARGET_ID = il.ID
 LEFT JOIN
     CAMPAIGN_CODES cc
 ON
     pu.CAMPAIGN_CODE_ID = cc.ID
 LEFT JOIN
     (
         SELECT
             OLD_SUBSCRIPTION_CENTER,
             OLD_SUBSCRIPTION_ID,
             STOP_CHANGE_TIME,
             STOP_CANCEL_TIME,
             STOP_PERSON_ID
         FROM
             (
                 SELECT
                     scStop.OLD_SUBSCRIPTION_CENTER,
                     scStop.OLD_SUBSCRIPTION_ID,
                     scStop.CHANGE_TIME                                                                                                     AS STOP_CHANGE_TIME,
                     cp.external_id                                                                                                         AS STOP_PERSON_ID,
                     scStop.CANCEL_TIME                                                                                                     AS STOP_CANCEL_TIME,
                     rank() over (partition BY scStop.OLD_SUBSCRIPTION_CENTER, scStop.OLD_SUBSCRIPTION_ID ORDER BY scStop.CHANGE_TIME DESC) AS rnk
                 FROM
                     SUBSCRIPTION_CHANGE scStop
                 JOIN
                     employees emp
                 ON
                     emp.center = scStop.EMPLOYEE_CENTER
                     AND emp.id = scStop.EMPLOYEE_ID
                 JOIN
                     PERSONS p
                 ON
                     emp.PERSONCENTER = p.center
                     AND emp.PERSONID = p.id
                 JOIN
                     persons cp
                 ON
                     cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
                     AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                 WHERE
                     scStop.TYPE = 'END_DATE' ) x
         WHERE
             rnk = 1) scStop
 ON
     scStop.OLD_SUBSCRIPTION_CENTER = s_old.CENTER
     AND scStop.OLD_SUBSCRIPTION_ID = s_old.ID
 WHERE
    ss.SUBSCRIPTION_CENTER in (:Centers)
    AND ss.SALES_DATE >= :From_Date
    AND ss.SALES_DATE <=  :To_Date
    -- Exclude from the following product groups:
    -- 4601 Exclude from Member Count
    -- 5406 Mem Cat: Junior DD
    -- 5407 Mem Cat: Jnr PAYP
    AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl
                    WHERE
                     pl.PRODUCT_CENTER = s_old.SUBSCRIPTIONTYPE_CENTER
                     AND pl.PRODUCT_ID = s_old.SUBSCRIPTIONTYPE_ID
                     AND pl.PRODUCT_GROUP_ID in (4601,5407,5406)
                    )
    AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl
                    WHERE
                     pl.PRODUCT_CENTER = s_new.SUBSCRIPTIONTYPE_CENTER
                     AND pl.PRODUCT_ID = s_new.SUBSCRIPTIONTYPE_ID
                     AND pl.PRODUCT_GROUP_ID = 4601
                    )

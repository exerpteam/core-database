-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
     FULLNAME                    AS "Full name",
     sales_date                  AS "Data upgrade",
     OLD_SUB_CREATION_DATE       AS "Sales Date Old Sub",
     PREVIOUS_SUBSCRIPTION_PRICE AS "Dues old sub",
     NEW_SUBSCRIPTION_PRICE      AS "Dues new sub",
     OLD_SUB_BED                 AS "Binding end date old sub",
     OLD_SUB_END_DATE            AS "Stop date old sub",
     NEW_SUB_START_DATE          AS "Start date new sub",
     NEW_SUB_DURATION            AS "New sub duration",
     NEW_SUB_CAMPAIGN            AS "Startup campaign name",
     NEW_SUB_CAMPAIGN_CODE       AS "Startup campaign code",
     STAFF_PEA                   AS "Staff Upgrade",
     CLUB,
     ID_MEMBER,
     OLD_SUBSCRIPTION AS "Old Short Subscription",
     NEW_SUBSCRIPTION AS "New Long Subscription",
     STAFF            AS "Staff Name"
 FROM
     (
         SELECT
             c.SHORTNAME                           CLUB ,
             ns.OWNER_CENTER || 'p' || ns.OWNER_ID ID_MEMBER ,
             p.fullname,
             sub_sale.sales_date,
             CASE
                 WHEN ost.ST_TYPE = 0
                 AND ost.PERIODCOUNT >= 12
                 AND ost.periodunit = 2
                 THEN 'LONG'
                 WHEN ost.ST_TYPE = 0
                 AND ost.PERIODCOUNT >= 1
                 AND ost.periodunit = 3
                 THEN 'LONG'
                 WHEN ost.ST_TYPE = 1
                 AND ost.BINDINGPERIODCOUNT >= 12
                 AND ost.periodunit = 2
                 THEN 'LONG'
                 WHEN ost.ST_TYPE = 1
                 AND ost.BINDINGPERIODCOUNT >= 1
                 AND ost.periodunit = 3
                 THEN 'LONG'
                 ELSE 'SHORT'
             END PREVIOUS_SUBSCRIPTION_TYPE ,
             CASE
                 WHEN nst.ST_TYPE = 0
                 AND nst.PERIODCOUNT >= 12
                 AND nst.periodunit = 2
                 THEN 'LONG'
                 WHEN nst.ST_TYPE = 0
                 AND nst.PERIODCOUNT >= 1
                 AND nst.periodunit = 3
                 THEN 'LONG'
                 WHEN nst.ST_TYPE = 1
                 AND nst.BINDINGPERIODCOUNT >= 12
                 AND nst.periodunit = 2
                 THEN 'LONG'
                 WHEN nst.ST_TYPE = 1
                 AND nst.BINDINGPERIODCOUNT >= 1
                 AND nst.periodunit = 3
                 THEN 'LONG'
                 ELSE 'SHORT'
             END         NEW_SUBSCRIPTION_TYPE ,
             op.NAME     OLD_SUBSCRIPTION ,
             np.NAME     NEW_SUBSCRIPTION ,
             ep.FULLNAME STAFF,
             CASE
                 WHEN ost.ST_TYPE = 0
                 THEN os.binding_price
                 WHEN ost.ST_TYPE = 1
                 AND ost.BINDINGPERIODCOUNT >= 12
                 AND ost.periodunit = 2
                 THEN os.binding_price*ost.BINDINGPERIODCOUNT
                 WHEN ost.ST_TYPE = 1
                 AND ost.BINDINGPERIODCOUNT >= 1
                 AND ost.periodunit = 3
                 THEN os.binding_price*12*ost.BINDINGPERIODCOUNT
                 ELSE 0
             END PREVIOUS_SUBSCRIPTION_PRICE ,
             CASE
                 WHEN nst.ST_TYPE = 0
                 THEN ns.binding_price
                 WHEN nst.ST_TYPE = 1
                 AND nst.BINDINGPERIODCOUNT >= 12
                 AND nst.periodunit = 2
                 THEN ns.binding_price*nst.BINDINGPERIODCOUNT
                 WHEN nst.ST_TYPE = 1
                 AND nst.BINDINGPERIODCOUNT >= 1
                 AND nst.periodunit = 3
                 THEN ns.binding_price*12*nst.BINDINGPERIODCOUNT
                 ELSE 0
             END                                         NEW_SUBSCRIPTION_PRICE,
             longtodatetz(os.creation_time, c.TIME_ZONE) AS OLD_SUB_CREATION_DATE,
             os.binding_end_date                         AS OLD_SUB_BED,
             os.end_date                                 AS OLD_SUB_END_DATE,
             ns.start_date                               AS NEW_SUB_START_DATE,
             ns.binding_end_date - ns.start_date         AS NEW_SUB_DURATION,
             sc.name                                     AS NEW_SUB_CAMPAIGN,
             cc.code                                     AS NEW_SUB_CAMPAIGN_CODE,
             pea1.txtvalue                               AS STAFF_PEA
         FROM
             subscriptions ns
         JOIN
             PERSONs p
         ON
             p.center = ns.owner_center
         AND p.id = ns.owner_id
         JOIN
             subscription_sales sub_sale
         ON
             sub_sale.subscription_center = ns.center
         AND sub_sale.subscription_id = ns.id
         JOIN
             SUBSCRIPTIONTYPES nst
         ON
             nst.CENTER = ns.SUBSCRIPTIONTYPE_CENTER
         AND nst.ID = ns.SUBSCRIPTIONTYPE_ID
         JOIN
             PRODUCTS np
         ON
             np.CENTER = nst.CENTER
         AND np.id = nst.ID
         JOIN
             CENTERS c
         ON
             c.id = ns.OWNER_CENTER
         AND c.COUNTRY = 'IT'
         JOIN
             subscriptions os
         ON
             os.owner_center = ns.owner_center
         AND os.owner_id = ns.owner_id
         AND os.center ||'ss' || os.id != ns.center ||'ss' || ns.id
         AND TRUNC(ns.start_date) - TRUNC(os.end_date) BETWEEN 0 AND 30
         JOIN
             SUBSCRIPTIONTYPES ost
         ON
             ost.CENTER = os.SUBSCRIPTIONTYPE_CENTER
         AND ost.ID = os.SUBSCRIPTIONTYPE_ID
         JOIN
             PRODUCTS op
         ON
             op.CENTER = ost.CENTER
         AND op.id = ost.ID
         AND op.globalid != np.globalid
         JOIN
             EMPLOYEES emp
         ON
             emp.CENTER = sub_sale.EMPLOYEE_CENTER
         AND emp.id = sub_sale.EMPLOYEE_ID
         JOIN
             PERSONS ep
         ON
             ep.CENTER = emp.PERSONCENTER
         AND ep.ID = emp.PERSONID
         LEFT JOIN
             PRIVILEGE_USAGES pu
         ON
             ns.invoiceline_center = pu.target_center
         AND ns.invoiceline_id = pu.target_id
         AND ns.invoiceline_subid = pu.target_subid
         LEFT JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.ID = pu.GRANT_ID
         AND pg.GRANTER_SERVICE = 'StartupCampaign'
         LEFT JOIN
             startup_campaign sc
         ON
             sc.id = pg.granter_id
         LEFT JOIN
             campaign_codes cc
         ON
             cc.id = ns.campaign_code_id
         LEFT JOIN
             PERSON_EXT_ATTRS pea1
         ON
             pea1.name ='Staff upgrade'
         AND pea1.PERSONCENTER = p.center
         AND pea1.PERSONID =p.id
         WHERE
             ns.sub_state NOT IN (7,8)
         AND ns.start_date <= COALESCE(ns.end_date, ns.start_date)
         AND os.sub_state NOT IN (7,8)
         AND os.start_date <= COALESCE(os.end_date, os.start_date)
         AND sub_sale.owner_center IN ($$scope$$)
         AND TRUNC(sub_sale.sales_date) BETWEEN TRUNC(CAST($$from_date$$ AS DATE)) AND TRUNC(CAST($$to_date$$ AS DATE))
         AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK npgl,
                     product_group npg
                 WHERE
                     npgl.product_center = np.center
                 AND npgl.product_id = np.id
                 AND npg.id = npgl.product_group_id
                 AND npg.name IN ('Exclude from Member Count',
                                  'Mem Cat: Jnr PAYP',
                                  'Mem Cat: Junior DD'))
         AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK opgl,
                     product_group opg
                 WHERE
                     opgl.product_center = op.center
                 AND opgl.product_id = op.id
                 AND opg.id = opgl.product_group_id
                 AND opg.name IN ('Exclude from Member Count',
                                  'Mem Cat: Jnr PAYP',
                                  'Mem Cat: Junior DD')) )mem_change
 WHERE
     mem_change.PREVIOUS_SUBSCRIPTION_TYPE = 'LONG'
 AND mem_change.NEW_SUBSCRIPTION_TYPE = 'LONG'
 AND NEW_SUBSCRIPTION_PRICE > PREVIOUS_SUBSCRIPTION_PRICE

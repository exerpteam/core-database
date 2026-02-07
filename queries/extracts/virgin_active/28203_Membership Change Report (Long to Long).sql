 SELECT DISTINCT
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
             END NEW_SUBSCRIPTION_PRICE
         FROM
             subscriptions ns
         JOIN
             (
                 SELECT
                     ss.subscription_center,
                     ss.subscription_id,
                     ss.employee_center,
                     ss.employee_id
                 FROM
                     subscription_sales ss
                 WHERE
                     ss.owner_center IN ($$scope$$)
                     AND TRUNC(ss.sales_date) BETWEEN TRUNC($$from_date$$) AND TRUNC($$to_date$$) ) sub_sale
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
             AND trunc(ns.start_date) - trunc(os.end_date) between 0 and  30
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
         WHERE
                     ns.sub_state NOT IN (7,8)
             and ns.start_date <= COALESCE(ns.end_date, ns.start_date)
                         AND os.sub_state NOT IN (7,8)
             and os.start_date <= COALESCE(os.end_date, os.start_date)
             AND NOT EXISTS
             (SELECT 1 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK npgl,
                     product_group npg
                 WHERE
                     npgl.product_center = np.center
                     AND npgl.product_id = np.id
                     AND npg.id = npgl.product_group_id
                     AND npg.name IN ('Exclude from Member Count', 'Mem Cat: Jnr PAYP', 'Mem Cat: Junior DD'))
             AND NOT EXISTS
             (SELECT 1 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK opgl,
                     product_group opg
                 WHERE
                     opgl.product_center = op.center
                     AND opgl.product_id = op.id
                     AND opg.id = opgl.product_group_id
                     AND opg.name IN ('Exclude from Member Count', 'Mem Cat: Jnr PAYP', 'Mem Cat: Junior DD')) )mem_change
 WHERE
     mem_change.PREVIOUS_SUBSCRIPTION_TYPE = 'LONG'
     AND mem_change.NEW_SUBSCRIPTION_TYPE = 'LONG'
     AND NEW_SUBSCRIPTION_PRICE > PREVIOUS_SUBSCRIPTION_PRICE

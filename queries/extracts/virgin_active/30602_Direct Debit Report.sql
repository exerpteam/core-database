 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             TRUNC(CAST($$From_Date$$ AS DATE), 'MONTH')                                               AS FromDate,
             TRUNC(add_months(CAST($$From_Date$$ AS DATE), 1), 'MONTH') - 1                            AS ToDate,
             (TRUNC(add_months(CAST($$From_Date$$ AS DATE), 1), 'MONTH')) - TRUNC(CAST($$From_Date$$ AS DATE), 'MONTH') AS NumDays
         
     )
     ,
     -- All free period starting within filter date
     free_period AS
     (
         SELECT
             s.CENTER,
             s.ID,
             srp.START_DATE AS START_DATE,
             srp.END_DATE   AS END_DATE,
             1              AS FREETOALL
         FROM
             SUBSCRIPTIONS s
         CROSS JOIN
             params
         JOIN
             SUBSCRIPTION_REDUCED_PERIOD srp -- Free periods assigned by a startup campaign, as a use of the free days that were stored or all manually assigned free periods
         ON
             srp.SUBSCRIPTION_CENTER = s.center
             AND srp.SUBSCRIPTION_ID = s.id
             AND srp.state = 'ACTIVE'
             AND srp.type IN ('SAVED_FREE_DAYS_USE',
                              'FREE_ASSIGNMENT')
         WHERE
             srp.START_DATE BETWEEN params.FromDate AND params.ToDate
             AND s.owner_center IN ($$scope$$)
         UNION
         SELECT
             s.CENTER,
             s.ID,
             sp.FROM_DATE AS START_DATE,
             sp.TO_DATE   AS END_DATE,
             0            AS FREETOALL
         FROM
             PRIVILEGE_USAGES pu
         CROSS JOIN
             params
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.ID = pu.GRANT_ID
         JOIN
             SUBSCRIPTION_PRICE sp -- All periods of PRICE = 0 created by a startup campaign
         ON
             sp.ID = pu.TARGET_ID
             AND sp.PRICE = 0
         JOIN
             SUBSCRIPTIONS s
         ON
             s.center = sp.SUBSCRIPTION_CENTER
             AND s.id = sp.SUBSCRIPTION_ID
         WHERE
             pu.TARGET_SERVICE = 'SubscriptionPrice'
             AND pu.state != 'CANCELLED'
             AND pg.GRANTER_SERVICE = 'StartupCampaign'
             AND sp.FROM_DATE BETWEEN params.FromDate AND params.ToDate
             AND s.owner_center IN ($$scope$$)
             AND sp.TYPE != 'PRORATA'
             AND sp.CANCELLED = 0
     )
     ,
     -- All free period including number of days within filter date
     free_period_days AS
     (
         SELECT
             fr.*,
             (
                 CASE
                     WHEN fr.end_date < params.ToDate
                     THEN fr.end_date
                     ELSE params.ToDate
                 END) - (
                 CASE
                     WHEN fr.start_date > params.FromDate
                     THEN fr.start_date
                     ELSE params.FromDate
                 END) + 1 AS Number_of_days
         FROM
             free_period fr
         CROSS JOIN
             params
     )
     ,
     -- All price update starting within filter date
     price_update AS
     (
         SELECT
             s.CENTER,
             s.ID,
             sp.price,
             sp.from_date,
             COALESCE(sp.to_date, params.ToDate) AS to_date
         FROM
             SUBSCRIPTIONS s
         JOIN
             subscriptiontypes st
         ON
             st.center = s.subscriptiontype_center
             AND st.id = s.subscriptiontype_id
             AND st.st_type = 1
         CROSS JOIN
             params
         JOIN
             SUBSCRIPTION_PRICE sp
         ON
             sp.SUBSCRIPTION_CENTER = s.CENTER
             AND sp.SUBSCRIPTION_ID = s.id
             AND sp.CANCELLED = 0
         WHERE
             s.owner_center IN ($$scope$$)
             AND sp.from_date BETWEEN params.FromDate AND params.ToDate
     )
     ,
     -- All price update including number of days within filter date
     price_update_days AS
     (
         SELECT
             pu.*,
             (
                 CASE
                     WHEN pu.to_date < params.ToDate
                     THEN pu.to_date
                     ELSE params.ToDate
                 END) - (
                 CASE
                     WHEN pu.from_date > params.FromDate
                     THEN pu.from_date
                     ELSE params.FromDate
                 END) + 1 AS Number_of_days
         FROM
             price_update pu
         CROSS JOIN
             params
     )
     ,
     -- All freeze period starting within filter date
     freeze_period AS
     (
         SELECT DISTINCT
             s.center,
             s.id,
             fr.start_date,
             fr.end_date,
             freezeproduct.price
         FROM
             subscriptions s
         CROSS JOIN
             params
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             s.SUBSCRIPTIONTYPE_CENTER=st.center
             AND s.SUBSCRIPTIONTYPE_ID=st.id
             AND st.st_type = 1
         JOIN
             SUBSCRIPTION_FREEZE_PERIOD fr
         ON
             fr.subscription_center = s.center
             AND fr.subscription_id = s.id
             AND fr.state NOT IN ('CANCELLED')
         JOIN
             PRODUCTS freezeproduct
         ON
             freezeproduct.center = st.FREEZEPERIODPRODUCT_CENTER
             AND freezeproduct.id = st.FREEZEPERIODPRODUCT_ID
             AND freezeproduct.PTYPE=7
         WHERE
             s.owner_center IN ($$scope$$)
             AND fr.start_date BETWEEN params.FromDate AND params.ToDate
     )
     ,
     -- All freeze period including number of days within filter date
     freeze_period_days AS
     (
         SELECT
             fp.*,
             (
                 CASE
                     WHEN fp.end_date < params.ToDate
                     THEN fp.end_date
                     ELSE params.ToDate
                 END) - (
                 CASE
                     WHEN fp.start_date > params.FromDate
                     THEN fp.start_date
                     ELSE params.FromDate
                 END) + 1 AS Number_of_days
         FROM
             freeze_period fp
         CROSS JOIN
             params
     )
     ,
     v_all AS
     (
         SELECT DISTINCT
             center.name                         AS Club,
             s.owner_center || 'p' || s.owner_id AS PersonId,
             pd.name                             AS SubName,
             s.end_date                          AS sub_end_date,
             s.subscription_price,
             COALESCE(sp.price, s.subscription_price) AS price,
             m.cached_productname                AS AddOnName,
             sa.end_date                         AS addon_end_date,
             sa.individual_price_per_unit        AS addonprice,
             CASE
                 WHEN otherpayer.center IS NOT NULL
                 THEN otherpayer.center || 'p' || otherpayer.id
                 ELSE NULL
             END                                                         AS OtherPayerId,
             freepr.START_DATE                                           AS freepr_start_date,
             freepr.END_DATE                                             AS freepr_end_date,
             freepr.FREETOALL                                            AS freepr_freetoall,
             freepr.Number_of_days                                       AS freepr_num_of_days,
             priceup.from_date                                           AS priceup_start_date,
             priceup.to_date                                             AS priceup_end_date,
             priceup.price                                               AS priceup_price,
             priceup.Number_of_days                                      AS priceup_num_of_days,
             freezepr.start_date                                         AS freezepr_start_date,
             freezepr.end_date                                           AS freezepr_end_date,
             freezepr.price                                              AS freezepr_price,
             freezepr.Number_of_days                                     AS freezepr_num_of_days,
             pc.deduction_date                                           AS membersdeductionday,
             otherpayerpc.deduction_date                                 AS otherpayerdeductiondate,
             COALESCE(pc.deduction_date, COALESCE(otherpayerpc.deduction_date, 1)) AS deductionday
         FROM
             subscriptions s
         JOIN
             CENTERS center
         ON
             center.id = s.owner_center
         CROSS JOIN
             params
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             s.SUBSCRIPTIONTYPE_CENTER=st.center
             AND s.SUBSCRIPTIONTYPE_ID=st.id
             AND st.st_type = 1
         JOIN
             PRODUCTS pd
         ON
             st.center=pd.center
             AND st.id=pd.id
         JOIN
             account_receivables ar
         ON
             ar.customercenter = s.owner_center
             AND ar.customerid = s.owner_id
             AND ar.ar_type = 4
         JOIN
             PAYMENT_ACCOUNTS pac
         ON
             pac.CENTER = ar.CENTER
             AND pac.ID = ar.ID
         LEFT JOIN
             PAYMENT_AGREEMENTS pag
         ON
             pac.ACTIVE_AGR_CENTER = pag.CENTER
             AND pac.ACTIVE_AGR_ID = pag.ID
             AND pac.ACTIVE_AGR_SUBID = pag.SUBID
         LEFT JOIN
             payment_cycle_config pc
         ON
             pc.id = pag.payment_cycle_config_id
         LEFT JOIN
             relatives otherpayer
         ON
             otherpayer.relativecenter = s.owner_center
             AND otherpayer.relativeid = s.owner_id
             AND otherpayer.rtype = 12
             AND otherpayer.status < 3
         LEFT JOIN
             account_receivables otherpayerar
         ON
             otherpayerar.customercenter = otherpayer.center
             AND otherpayerar.customerid = otherpayer.id
             AND otherpayerar.ar_type = 4
         LEFT JOIN
             PAYMENT_ACCOUNTS otherpayerpac
         ON
             otherpayerpac.CENTER = otherpayerar.CENTER
             AND otherpayerpac.ID = otherpayerar.ID
         LEFT JOIN
             PAYMENT_AGREEMENTS otherpayerpag
         ON
             otherpayerpac.ACTIVE_AGR_CENTER = otherpayerpag.CENTER
             AND otherpayerpac.ACTIVE_AGR_ID = otherpayerpag.ID
             AND otherpayerpac.ACTIVE_AGR_SUBID = otherpayerpag.SUBID
         LEFT JOIN
             payment_cycle_config otherpayerpc
         ON
             otherpayerpc.id = otherpayerpag.payment_cycle_config_id
         LEFT JOIN
             subscription_addon sa
         ON
             sa.subscription_center = s.center
             AND sa.subscription_id = s.id
             AND sa.cancelled = 0
             AND sa.start_date <= params.FromDate
             AND COALESCE(sa.end_date, params.ToDate) > params.FromDate
         LEFT JOIN
             MASTERPRODUCTREGISTER m
         ON
             sa.ADDON_PRODUCT_ID=m.ID
         LEFT JOIN
             SUBSCRIPTION_PRICE sp
         ON
             sp.SUBSCRIPTION_CENTER = s.CENTER
             AND sp.SUBSCRIPTION_ID = s.id
             AND sp.CANCELLED = 0
             AND sp.from_date <= params.FromDate
             AND COALESCE(sp.to_date, params.ToDate) > params.FromDate
         LEFT JOIN
             free_period_days freepr
         ON
             freepr.center = s.center
             AND freepr.id = s.id
         LEFT JOIN
             price_update_days priceup
         ON
             priceup.center = s.center
             AND priceup.id = s.id
         LEFT JOIN
             freeze_period_days freezepr
         ON
             freezepr.center = s.center
             AND freezepr.id = s.id
         WHERE
             s.owner_center IN ($$scope$$)
             AND s.start_date <= params.FromDate
             AND COALESCE(s.end_date, params.ToDate) > params.FromDate
     )
 SELECT
     v.Club,
     v.PersonId,
     v.SubName AS "Subscription Name",
     CASE
         WHEN v.sub_end_date < params.ToDate
         THEN
             CASE
                 WHEN v.freepr_start_date <= params.FromDate
                     AND v.freepr_end_date >= v.sub_end_date
                 THEN 0
                 WHEN v.freezepr_start_date <= params.FromDate
                     AND v.freezepr_end_date >= v.sub_end_date
                 THEN ROUND((v.freezepr_price/params.NumDays)*(v.sub_end_date-params.FromDate+1), 2)
                 WHEN v.priceup_start_date <= params.FromDate
                     AND v.priceup_end_date >= v.sub_end_date
                 THEN ROUND((v.priceup_price/params.NumDays)*(v.sub_end_date-params.FromDate+1), 2)
                 ELSE ROUND((v.price/params.NumDays)*(v.sub_end_date-params.FromDate+1), 2)
             END
         ELSE
             CASE
                 WHEN v.freepr_start_date <= params.FromDate
                     AND v.freepr_end_date >= params.ToDate
                 THEN 0
                 WHEN v.freezepr_start_date <= params.FromDate
                     AND v.freezepr_end_date >= params.ToDate
                 THEN v.freezepr_price
                 WHEN v.priceup_start_date <= params.FromDate
                     AND v.priceup_end_date >= params.ToDate
                 THEN v.priceup_price
                 WHEN v.freepr_num_of_days IS NOT NULL
                     OR v.priceup_num_of_days IS NOT NULL
                     OR v.freezepr_num_of_days IS NOT NULL
                 THEN
                     CASE
                         WHEN v.freepr_num_of_days = v.priceup_num_of_days
                         THEN COALESCE(ROUND((v.price/params.NumDays)*(params.NumDays-v.freepr_num_of_days), 2), 0) + COALESCE(ROUND((v.freezepr_price/params.NumDays)*(v.freezepr_num_of_days), 2), 0)
                         ELSE COALESCE(ROUND((v.price/params.NumDays)*(params.NumDays-COALESCE(v.freepr_num_of_days, 0)-COALESCE(v.priceup_num_of_days, 0)-COALESCE(v.freezepr_num_of_days, 0)), 2), 0) + COALESCE(ROUND((v.priceup_price/params.NumDays)*(v.priceup_num_of_days), 2), 0) + COALESCE(ROUND((v.freezepr_price/params.NumDays)*(v.freezepr_num_of_days), 2), 0)
                     END
                 ELSE v.price
             END
     END         AS "Subscription Amount",
     v.AddOnName AS "AddOn Name",
     CASE
         WHEN v.freepr_start_date <= params.FromDate
             AND v.freepr_end_date >= params.ToDate
             AND v.freepr_freetoall = 1
         THEN 0
         WHEN v.freezepr_start_date <= params.FromDate
             AND v.freezepr_end_date >= params.ToDate
         THEN 0
         WHEN v.addon_end_date < params.ToDate
         THEN ROUND((v.addonprice/params.NumDays)*(v.addon_end_date-params.FromDate+1), 2)
         ELSE v.addonprice
     END AS "AddOn Amount",
     CASE
         WHEN v.freepr_start_date <= params.FromDate
             AND v.freepr_end_date >= params.ToDate
         THEN TRUNC(v.freepr_end_date + 1, 'MONTH') + v.deductionday -1
         WHEN v.freezepr_start_date <= params.FromDate
             AND v.freezepr_end_date >= params.ToDate
             AND v.freezepr_price = 0
         THEN TRUNC(v.freezepr_end_date + 1, 'MONTH') + v.deductionday -1
         WHEN v.priceup_start_date <= params.FromDate
             AND v.priceup_end_date >= params.ToDate
             AND v.priceup_price = 0
         THEN TRUNC(v.priceup_end_date + 1, 'MONTH') + v.deductionday -1
         ELSE params.FromDate+ v.deductionday -1
     END AS "Next Deduction Date",
     v.OtherPayerId
 FROM
     v_all v
 CROSS JOIN
     params

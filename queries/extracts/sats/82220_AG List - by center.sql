-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         centerid,
         centername,
         SUM (COUNT) AS total
    FROM
         (
            WITH
                     params AS
                     (
                      SELECT
                                 /*+ materialize */
                                 c.id AS center_id,
                                 --c.name                                                                                             AS center_name,
                                 datetolongTZ (TO_CHAR (current_timestamp, 'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) - cast(90 as bigint) * 24 * 3600 * 1000 AS cutDate --minus
                                 -- 90 days
                            FROM
                                 centers c
                            JOIN
                                 countries co
                              ON
                                 co.id = c.country
                                 AND c.country = 'SE' --sweden
                     )
              SELECT
                         cen.id   AS centerid,
                         cen.name AS centername,
                         COUNT(*) AS COUNT
                    FROM
                         CASHCOLLECTIONCASES CCC
                    JOIN
                         params
                      ON
                         params.center_id = CCC.PERSONCENTER
              INNER JOIN
                         PERSONS PE
                      ON
                         (
                             CCC.PERSONCENTER = PE.CENTER
                             AND CCC.PERSONID = PE.ID)
              INNER JOIN
                         ACCOUNT_RECEIVABLES AR
                      ON
                         (
                             AR.CUSTOMERCENTER = PE.CENTER
                             AND AR.CUSTOMERID = PE.ID
                             AND AR.AR_TYPE = 4)
                         --1 = Cash account
                         --4 = Payment account
                         --5 = Debt collection account
                         --6 = installment plan account
               LEFT JOIN
                         PAYMENT_ACCOUNTS PAA
                      ON
                         (
                             PAA.CENTER = AR.CENTER
                             AND PAA.ID = AR.ID)
               LEFT JOIN
                         PAYMENT_AGREEMENTS PAG1
                      ON
                         (
                             PAA.ACTIVE_AGR_CENTER = PAG1.CENTER
                             AND PAA.ACTIVE_AGR_ID = PAG1.ID
                             AND PAA.ACTIVE_AGR_SUBID = PAG1.SUBID)
                    JOIN
                         subscriptions s
                      ON
                         s.owner_center = pe.center
                         AND s.owner_id = pe.id
                    JOIN
                         subscriptiontypes st
                      ON
                         st.center = s.subscriptiontype_center
                         AND st.ID = s.subscriptiontype_id
                    JOIN
                         products prod
                      ON
                         prod.center = st.center
                         AND prod.id = st.id
                    JOIN
                         product_and_product_group_link ppgl
                      ON
                         prod.center = ppgl.product_center
                         AND prod.id = ppgl.product_id
                    JOIN
                         product_group pg
                      ON
                         ppgl.product_group_id = pg.id
                    JOIN
                         subscription_sales ss
                      ON
                         s.center = ss.subscription_center
                         AND s.id = ss.subscription_id
               LEFT JOIN
                         employees emp
                      ON
                         ss.EMPLOYEE_CENTER = emp.center
                         AND ss.EMPLOYEE_ID = emp.id
               LEFT JOIN
                         persons salep
                      ON
                         emp.personcenter = salep.center
                         AND emp.personid = salep.id
                    JOIN
                         centers cen
                      ON
                         s.owner_center = cen.id
                   WHERE
                         CCC.MISSINGPAYMENT = 0 --0 missing agreement. 1 cash collection case
                         AND pg.id = 99 --99 EFT Memberships
                         AND s.sub_state != 6 --6 transferred
                         AND CCC.CLOSED = 0
                         AND CCC.CASHCOLLECTIONSERVICE IS NULL
                         AND datetolongC (TO_CHAR (ss.start_date, 'YYYY-MM-DD HH24:MI'), s.center) >= params.cutDate
                GROUP BY
                         cen.id,
                         cen.name
 UNION
              SELECT
                         cen.id   AS centerid,
                         cen.name AS centername,
                         COUNT(*) AS COUNT
                    FROM
                         CASHCOLLECTIONCASES CCC
                    JOIN
                         params
                      ON
                         params.center_id = CCC.PERSONCENTER
              INNER JOIN
                         relatives r
                      ON
                         CCC.PERSONCENTER = r.center
                         AND CCC.PERSONID = r.id
                         AND r.status = 1 --1 = Active (Documentation valid)
                         AND r.rtype = 12 -- Other payer -- Customer paying (PERSONS.CENTER, PERSONS.ID)
                    JOIN
                         PERSONS PE
                      ON
                         (
                             r.relativecenter = PE.CENTER
                             AND r.relativeid = PE.ID)
                    JOIN
                         ACCOUNT_RECEIVABLES AR
                      ON
                         (
                             AR.CUSTOMERCENTER = r.center
                             AND AR.CUSTOMERID = r.id
                             AND AR.AR_TYPE = 4)
                         --1 = Cash account
                         --4 = Payment account
                         --5 = Debt collection account
                         --6 = installment plan account
               LEFT JOIN
                         PAYMENT_ACCOUNTS PAA
                      ON
                         (
                             PAA.CENTER = AR.CENTER
                             AND PAA.ID = AR.ID)
               LEFT JOIN
                         PAYMENT_AGREEMENTS PAG1
                      ON
                         (
                             PAA.ACTIVE_AGR_CENTER = PAG1.CENTER
                             AND PAA.ACTIVE_AGR_ID = PAG1.ID
                             AND PAA.ACTIVE_AGR_SUBID = PAG1.SUBID)
                    JOIN
                         subscriptions s
                      ON
                         s.owner_center = pe.center
                         AND s.owner_id = pe.id
                    JOIN
                         subscriptiontypes st
                      ON
                         st.center = s.subscriptiontype_center
                         AND st.ID = s.subscriptiontype_id
                    JOIN
                         products prod
                      ON
                         prod.center = st.center
                         AND prod.id = st.id
                    JOIN
                         product_and_product_group_link ppgl
                      ON
                         prod.center = ppgl.product_center
                         AND prod.id = ppgl.product_id
                    JOIN
                         product_group pg
                      ON
                         ppgl.product_group_id = pg.id
                    JOIN
                         subscription_sales ss
                      ON
                         s.center = ss.subscription_center
                         AND s.id = ss.subscription_id
               LEFT JOIN
                         employees emp
                      ON
                         ss.EMPLOYEE_CENTER = emp.center
                         AND ss.EMPLOYEE_ID = emp.id
               LEFT JOIN
                         persons salep
                      ON
                         emp.personcenter = salep.center
                         AND emp.personid = salep.id
                    JOIN
                         centers cen
                      ON
                         s.owner_center = cen.id
                   WHERE
                         CCC.MISSINGPAYMENT = 0 --0 missing agreement. 1 cash collection case
                         AND pg.id = 99 --99 EFT Memberships
                         AND s.sub_state != 6 --6 transferred
                         AND CCC.CLOSED = 0
                         AND CCC.CASHCOLLECTIONSERVICE IS NULL
                         AND datetolongC (TO_CHAR (ss.start_date, 'YYYY-MM-DD HH24:MI'), s.center) >= params.cutDate
                GROUP BY
                         cen.id,
                         cen.name) t
 GROUP BY
         centerid,
         centername
 ORDER BY
         total DESC

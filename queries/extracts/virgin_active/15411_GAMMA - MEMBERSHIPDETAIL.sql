-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             c.id                               AS center_id,
             current_timestamp AS from_date,
             dateToLongC(getcentertime(c.id), c.ID) + 24*60*60*1000 AS  today,
             dateToLongC(getcentertime(c.id), c.ID) - 3*24*60*60*1000 AS three_days_ago
         FROM
             CENTERS c
         WHERE
             c.country = 'IT'
     )
 SELECT DISTINCT
    -- p.CENTER,
    -- p.ID,
     s.CENTER || 'ss' || s.ID "MembershipDetailID",
     p.EXTERNAL_ID            "PersonID",
     s.CENTER || 'ss' || s.ID "MembershipNumber",
     pg.name                  "MembershipCategory",
     pg.name                  "MembershipGroup",
     CASE st.ST_TYPE
             WHEN 0 THEN  'FIXED_LENGTH'
             WHEN 1 THEN  'RECURRING'
             ELSE 'UNDEFINED' END                      "MembershipType",
     st.BINDINGPERIODCOUNT                    "MembershipDuration",
     s.CREATOR_CENTER ||'emp' || s.CREATOR_ID "SoldBy",
     p.FIRST_ACTIVE_START_DATE                "InitialJoinDate",
     s.BINDING_END_DATE                       "ObligationDate",
     CASE st.ST_TYPE
             WHEN 0 THEN 'FIXED'
             WHEN 1 THEN 'RECURRING'
             ELSE 'UNDEFINED' END "AutoRenewMembership",
     longToDate(s.CREATION_TIME) "JoinDate",
     s.START_DATE             "StartDate",
     s.END_DATE               "CostingDate",
     s.END_DATE               "ExpiryDate",
     s.CENTER || 'ss' || s.ID "SubscriptionReference",
     CASE st.ST_TYPE
             WHEN 0 THEN 'FIXED'
             WHEN 1 THEN 'RECURRING'
             ELSE 'UNDEFINED' END               "SubscriptionType",
     s.CENTER                          "SiteID",
     prod.CENTER || 'prod' || prod.ID  "ProductID",
     ch.NAME                           "PaymentMethod",
     s.STATE                           "SubscriptionStatus",
     s.SUB_STATE                       "SubscriptionSubStatus",
     otherP.CENTER || 'p' || otherP.ID "PrimaryPaysInd",
     CASE
         WHEN st.BINDINGPERIODCOUNT IS NULL
         THEN
             CASE
                 WHEN prod.NAME LIKE 'Tessera%'
                 THEN 0
                 ELSE
                     CASE
                         WHEN PERIODUNIT = 1
                         AND PERIODCOUNT >= 365
                         THEN 1
                         WHEN PERIODUNIT = 1
                         AND PERIODCOUNT < 365
                         THEN 0
                         WHEN PERIODUNIT = 2
                         AND PERIODCOUNT >= 12
                         THEN 1
                         WHEN PERIODUNIT = 2
                         AND PERIODCOUNT < 12
                         THEN 0
                         ELSE 1
                     END
             END
         ELSE
             CASE
                 WHEN st.BINDINGPERIODCOUNT >= 12
                 THEN 1
                 ELSE 0
             END
     END "SalesMix"
 FROM
     SUBSCRIPTIONS s
 JOIN
     PARAMS
 ON
     PARAMS.CENTER_ID = S.CENTER
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
 AND p.ID = s.OWNER_ID
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
 AND st.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
 AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.CENTER
 AND ar.CUSTOMERID = p.ID
 AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
 AND pac.ID = ar.ID
 LEFT JOIN
     PAYMENT_AGREEMENTS pagr
 ON
     pagr.CENTER = pac.ACTIVE_AGR_CENTER
 AND pagr.ID = pac.ACTIVE_AGR_ID
 AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
 LEFT JOIN
     CLEARINGHOUSES ch
 ON
     ch.ID = pagr.CLEARINGHOUSE
 LEFT JOIN
     RELATIVES otherP
 ON
     otherP.RELATIVECENTER = p.CENTER
 AND otherP.RELATIVEID = p.ID
 AND otherP.RTYPE = 12
 AND otherP.STATUS = 1
 WHERE
   (s.state != 3
   OR
   EXISTS (SELECT 1 FROM STATE_CHANGE_LOG scl WHERE scl.center = s.center AND scl.id = s.id AND scl.ENTRY_TYPE = 2 AND s.state = 3 AND scl.BOOK_START_TIME > params.three_days_ago AND scl.BOOK_START_TIME < params.today)
   )

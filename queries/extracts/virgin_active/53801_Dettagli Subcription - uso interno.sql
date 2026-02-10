-- The extract is extracted from Exerp on 2026-02-08
-- solo per uso interno
 select distinct * from (
 SELECT
     mpr.ID "Master Product ID",
     prod.CENTER,
     c.NAME "center name",
     prod.GLOBALID "Global Name",
     prod.NAME "Product Name",
     pac.NAME "Account Configuration",
     sales_acc.EXTERNAL_ID AS "Sales Account",
     r.ROLENAME "Required Role",
     pjf.NEEDS_PRIVILEGE "Purchase Require Privilege",
     mpr.CACHED_PRODUCTPRICE "Top Level Price",
     prod.PRICE "Club Price",
         st.ROUNDUP_END_UNIT,
     st.RANK                                         "Rank",
     CASE st.ST_TYPE WHEN 0 THEN 'CASH' WHEN 1 THEN 'EFT' ELSE 'UNDEFINED' END "Deduction",
     CASE st.PERIODUNIT  WHEN 0 THEN 'WEEK' WHEN 1 THEN 'DAY' WHEN 2 THEN 'MONTH' WHEN 3 THEN 'YEAR' WHEN 4 THEN 'HOUR' WHEN 5 THEN 'MINUTE' WHEN 6 THEN 'SECOND' ELSE 'UNDEFINED' END "Period Unit",
     st.EXTEND_BINDING_BY_PRORATA "Ext. bind By prorata",
     st.IS_ADDON_SUBSCRIPTION "Requires Main Subscription",
     mpr.USE_CONTRACT_TEMPLATE "Use Contract Template",
     FIRST_VALUE(t.description) OVER (PARTITION BY mpr.DEFINITION_KEY ORDER BY mpr.SCOPE_TYPE desc) test,
 --      -- Added by VA
 --      CASE
 --              WHEN t.description IS NOT NULL then t.description
 --              ELSE 'Default'
 --      END AS "Template",
 --      -- End Change by VA
     st.RENEW_WINDOW "Renew Period",
     st.PERIODCOUNT "Period Count",
     pg.NAME "sub primary Product Group",
     pgAll.NAME "all sub groups",
     pgProRataPrimary.NAME "primary pro rata group",
     pgAllProRata.NAME "all pro rata groups",
     pgCreationPrimary.NAME "primary cretaion group",
     pgAllCreation.NAME "all creation groups",
     st.BINDINGPERIODCOUNT "Binding Period",
     st.PRORATAPERIODCOUNT "Prorata p.",
     st.INITIALPERIODCOUNT "Initial p.",
     fp.PRICE "Price During Freeze",
     CASE
         WHEN st.FREEZELIMIT IS NULL
         THEN 0
         ELSE 1
     END AS "can be frozen",
     CASE
         WHEN st.FREEZELIMIT IS NOT NULL
         THEN CAST((xpath('FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@LENGTH', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR) || ' ' || CAST((xpath('FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@UNIT', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR)
		 ELSE NULL
     END AS "Within a period of",
     CASE
         WHEN st.FREEZELIMIT IS NOT NULL
         THEN CAST((xpath('FREEZELIMIT/@MINDURATION', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR)
		 ELSE NULL
     END AS "Min duration",
     CASE
         WHEN st.FREEZELIMIT IS NOT NULL
		 THEN CAST((xpath('FREEZELIMIT/@MINDURATION_UNIT', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR)
         ELSE NULL
     END AS "Min duration Unit",
     CASE
         WHEN st.FREEZELIMIT IS NOT NULL
         THEN CAST((xpath('FREEZELIMIT/@MAXDURATION', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR)
		 ELSE NULL
     END AS "Max duration",
     CASE
         WHEN st.FREEZELIMIT IS NOT NULL
         THEN CAST((xpath('FREEZELIMIT/@MAXDURATION_UNIT', xmlparse(document convert_from(st.FREEZELIMIT,'AL32UTF8'))))[1] AS VARCHAR)
		 ELSE NULL
     END AS "Max duration Unit",
     pjf.PRICE "Joining Fee Club Level",
     pacCreation.NAME "Joining fee account config" ,
     CASE
         WHEN st.PRORATAPRODUCT_CENTER IS NOT NULL
         THEN 1
         ELSE 0
     END AS "Use Pro Rata Period",
     pacProRata.NAME "Pro rata account config",
     CASE st.AGE_RESTRICTION_TYPE WHEN 1 THEN 'LESS THEN' WHEN 2 THEN 'MORE THEN' ELSE 'UNDEFINED' END "age restriction type",
     st.AGE_RESTRICTION_VALUE "Age",
     ps.NAME "Privilege Set Top Level",
     st.IS_PRICE_UPDATE_EXCLUDED
 FROM
     SUBSCRIPTIONTYPES st
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = st.CENTER
     AND prod.ID = st.ID
         and prod.blocked = 0
 JOIN
     CENTERS c
 ON
     c.id = prod.CENTER
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     PRODUCT_ACCOUNT_CONFIGURATIONS pac
 ON
     pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
 LEFT JOIN
     ACCOUNTS sales_acc
 ON
     sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
     AND sales_acc.CENTER = prod.CENTER
 JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.GLOBALID = prod.GLOBALID
 LEFT JOIN
     PRODUCTS fp
 ON
     fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER
     AND fp.ID = st.FREEZEPERIODPRODUCT_ID
 LEFT JOIN
     PRODUCTS pjf
 ON
     pjf.CENTER = prod.CENTER
     AND pjf.GLOBALID = 'CREATION_' || prod.GLOBALID
 LEFT JOIN
     PRODUCT_GROUP pgCreationPrimary
 ON
     pgCreationPrimary.ID = pjf.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     PRODUCT_ACCOUNT_CONFIGURATIONS pacCreation
 ON
     pacCreation.ID = pjf.PRODUCT_ACCOUNT_CONFIG_ID
 LEFT JOIN
     ROLES r
 ON
     r.ID = pjf.REQUIREDROLE
 LEFT JOIN
     PRODUCTS pProRata
 ON
     pProRata.CENTER = prod.CENTER
     AND pProRata.GLOBALID = 'PRORATA_' || prod.GLOBALID
 LEFT JOIN
     PRODUCT_GROUP pgProRataPrimary
 ON
     pgProRataPrimary.ID = pProRata.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     PRODUCT_ACCOUNT_CONFIGURATIONS pacProRata
 ON
     pacProRata.ID = pProRata.PRODUCT_ACCOUNT_CONFIG_ID
 LEFT JOIN
     PRIVILEGE_GRANTS pgr
 ON
     pgr.GRANTER_ID = mpr.ID
     AND pgr.GRANTER_SERVICE = 'GlobalSubscription'
         AND pgr.VALID_TO is null
 LEFT JOIN
     PRIVILEGE_SETS ps
 ON
     ps.ID = pgr.PRIVILEGE_SET
 LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
 ON
     pgLink.PRODUCT_CENTER = prod.CENTER
     AND pgLink.PRODUCT_ID = prod.ID
 LEFT JOIN
     PRODUCT_GROUP pgAll
 ON
     pgAll.ID = pgLink.PRODUCT_GROUP_ID
 LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkProRata
 ON
     pgLinkProRata.PRODUCT_CENTER = pProRata.CENTER
     AND pgLinkProRata.PRODUCT_ID = pProRata.ID
 LEFT JOIN
     PRODUCT_GROUP pgAllProRata
 ON
     pgAllProRata.ID = pgLinkProRata.PRODUCT_GROUP_ID
 LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkCreation
 ON
     pgLinkCreation.PRODUCT_CENTER = pjf.CENTER
     AND pgLinkCreation.PRODUCT_ID = pjf.ID
 LEFT JOIN
     PRODUCT_GROUP pgAllCreation
 ON
     pgAllCreation.ID = pgLinkCreation.PRODUCT_GROUP_ID
 JOIN
     LICENSES li
 ON
     li.CENTER_ID = c.id
     AND li.FEATURE = 'clubLead'
 -- added by VA CW
 LEFT JOIN
         TEMPLATES T
 ON MPR.CONTRACT_TEMPLATE_ID = T.ID
 WHERE
     ((mpr.SCOPE_TYPE = 'C' and mpr.SCOPE_ID = st.CENTER) or (mpr.ID = mpr.DEFINITION_KEY))
     AND (
         pgr.ID IS NULL
         OR pgr.VALID_TO IS NULL )
     AND prod.center IN (:scope)
     AND(
         li.START_DATE <= CURRENT_TIMESTAMP
         AND (
             li.STOP_DATE > CURRENT_TIMESTAMP
             OR li.STOP_DATE IS NULL))
 ORDER BY
     mpr.GLOBALID,
     prod.CENTER, 
     ps.NAME) t1

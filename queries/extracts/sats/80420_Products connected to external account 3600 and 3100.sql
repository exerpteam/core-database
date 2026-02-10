-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
 prod.GLOBALID,
 prod.NAME,
 prod.PRICE,
 pgroup.NAME productGroup,
 --
 pac.SALES_ACCOUNT_GLOBALID as income_globalid,
 ac_income.name as income_name,
 ac_income.external_id as income_externalID,
 --
 pac.EXPENSES_ACCOUNT_GLOBALID,
 ac_expense.name,
 ac_expense.external_id,
 --
 pac.REFUND_ACCOUNT_GLOBALID,
 ac_refund.name,
 ac_refund.external_id
 FROM
      PRODUCTS prod
 join MASTERPRODUCTREGISTER mpr
 on
 mpr.GLOBALID = prod.GLOBALID
 and mpr.state not in ('DELETED','INACTIVE')
 left Join product_account_configurations pac
 on
      prod.product_account_config_id = pac.id
 LEFT JOIN PRODUCT_GROUP pgroup
 ON
      prod.PRIMARY_PRODUCT_GROUP_ID = pgroup.id
 left join accounts ac_income
 on
      ac_income.center = prod.center
 AND  ac_income.globalid = pac.sales_account_globalid
 left join accounts ac_expense
 on
      ac_expense.center = prod.center
 AND  ac_expense.globalid = pac.expenses_account_globalid
 left join accounts ac_refund
 on
      ac_refund.center = prod.center
 AND  ac_refund.globalid = pac.refund_account_globalid
 where
 ac_income.external_id in ('3600','3100') or ac_expense.external_id in ('3600','3100') or ac_refund.external_id in ('3600','3100')
 and prod.blocked = 0
 ORDER BY
      prod.GLOBALID

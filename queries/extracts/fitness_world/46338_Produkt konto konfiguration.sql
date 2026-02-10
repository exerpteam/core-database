-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
DISTINCT prod.GLOBALID, 
prod.NAME, 
prod.PRICE,
prod.COST_PRICE, 
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
ORDER BY 
     prod.GLOBALID




/*SELECT 
    distinct prod.GLOBALID, 
    prod.NAME, 
    prod.PRICE,
    pgroup.NAME productGroup,
    income.NAME incomeAccount, 
    income.GLOBALID incomeGlobalId, 
    income.EXTERNAL_ID incomeExternalId, 
    expense.NAME expenseAccount, 
    expense.GLOBALID expenseGlobalId, 
    expense.EXTERNAL_ID expenseExternalId, 
    refund.NAME refundAccount, 
    refund.GLOBALID refundGlobalId, 
    refund.EXTERNAL_ID refundExternalId 
FROM 
    PRODUCTS prod 

LEFT JOIN PRODUCT_GROUP pgroup 
	on 
		prod.PRIMARY_PRODUCT_GROUP_ID = pgroup.id

LEFT JOIN 
    ACCOUNTS income 
    ON 
    income.CENTER = prod.INCOME_ACCOUNTCENTER and income.ID = prod.INCOME_ACCOUNTID 
LEFT JOIN 
    ACCOUNTS expense 
    ON 
    expense.CENTER = prod.EXPENSE_ACCOUNTCENTER and expense.ID = prod.EXPENSE_ACCOUNTID 
LEFT JOIN 
    ACCOUNTS refund 
    ON 
    refund.CENTER = prod.REFUND_ACCOUNTCENTER and refund.ID = prod.REFUND_ACCOUNTID 
ORDER BY prod.GLOBALID 
*/
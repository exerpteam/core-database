SELECT 
    distinct prod.GLOBALID, 
    prod.NAME, 
    prod.PRICE,
    pgroup.NAME productGroup,
    income.NAME incomeAccount, 
    income.GLOBALID incomeGlobalId, 
    income.EXTERNAL_ID incomeExternalId, 
    vat_income.rate as VAT_on_income,
    expense.NAME expenseAccount, 
    expense.GLOBALID expenseGlobalId, 
    expense.EXTERNAL_ID expenseExternalId, 
    vat_expense.rate as VAT_on_Expenses,
    refund.NAME refundAccount, 
    refund.GLOBALID refundGlobalId, 
    refund.EXTERNAL_ID refundExternalId,
    vat_refund.rate as VAT_on_refund
FROM 
    PRODUCTS prod 
LEFT JOIN
    PRODUCTGROUPS pgroup
    on prod.PRODUCTGROUP_CENTER = pgroup.CENTER 
    and prod.PRODUCTGROUP_ID = pgroup.ID
LEFT JOIN 
    ACCOUNTS income 
    ON 
    income.CENTER = prod.INCOME_ACCOUNTCENTER 
    and income.ID = prod.INCOME_ACCOUNTID 
LEFT JOIN 
    ACCOUNTS expense 
    ON 
    expense.CENTER = prod.EXPENSE_ACCOUNTCENTER 
    and expense.ID = prod.EXPENSE_ACCOUNTID 
LEFT JOIN 
    ACCOUNTS refund 
    ON 
    refund.CENTER = prod.REFUND_ACCOUNTCENTER 
    and refund.ID = prod.REFUND_ACCOUNTID 
LEFT JOIN
    VAT_TYPES vat_income
    ON
       income.vat_center = vat_income.center
    and income.vat_id = vat_income.id
LEFT JOIN
    VAT_TYPES vat_refund
    ON
       refund.vat_center = vat_refund.center
    and refund.vat_id = vat_refund.id
LEFT JOIN
    VAT_TYPES vat_expense
    ON
       expense.vat_center = vat_expense.center
    and expense.vat_id = vat_expense.id
WHERE
	prod.center in (:Scope)
	AND prod.BLOCKED = 0
ORDER BY prod.GLOBALID

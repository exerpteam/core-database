 SELECT distinct
 prod.GLOBALID,
     prod.NAME,
     prod.PRICE,
     pac.name as account_config,
     pgroup.NAME productGroup,
     income2.NAME incomeAccount,
     income2.GLOBALID incomeGlobalId,
     income2.EXTERNAL_ID incomeExternalId,
     vat_income.rate as VAT_on_income,
     expense2.NAME expenseAccount,
     expense2.GLOBALID expenseGlobalId,
     expense2.EXTERNAL_ID expenseExternalId,
     vat_expense.rate as VAT_on_Expenses,
     refund2.NAME refundAccount,
     refund2.GLOBALID refundGlobalId,
     refund2.EXTERNAL_ID refundExternalId,
     vat_refund.rate as VAT_on_refund
 FROM
     PRODUCTS prod
 left join
     product_account_configurations pac
     on
     prod.product_account_config_id = pac.id
 left JOIN PRODUCT_GROUP pgroup
     on
         prod.PRIMARY_PRODUCT_GROUP_ID = pgroup.id
 left JOIN
     ACCOUNTS income2
     ON
     income2.globalid = pac.SALES_ACCOUNT_GLOBALID
     and income2.center = prod.center
 left JOIN
     ACCOUNTS expense2
     ON
     expense2.globalid = pac.EXPENSES_ACCOUNT_GLOBALID
     and expense2.center = prod.center
 left JOIN
     ACCOUNTS refund2
     ON
     refund2.globalid = pac.REFUND_ACCOUNT_GLOBALID
     and refund2.center = prod.center
 LEFT JOIN
     VAT_TYPES vat_income
     ON
        income2.center = vat_income.center
     and income2.id = vat_income.id
 LEFT JOIN
     VAT_TYPES vat_refund
     ON
        refund2.center = vat_refund.center
     and refund2.id = vat_refund.id
 LEFT JOIN
     VAT_TYPES vat_expense
     ON
        expense2.center = vat_expense.center
     and expense2.id = vat_expense.id
 WHERE
       prod.center in (:scope)
      and prod.BLOCKED = 0
 ORDER BY prod.GLOBALID

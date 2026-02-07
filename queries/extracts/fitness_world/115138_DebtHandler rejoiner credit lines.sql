-- This is the version from 2026-02-05
--  
SELECT
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS customer_key,
    at.text,
    at.amount,
    eclub2.longToDate(at.TRANS_TIME) AS trans_time,
    p.name AS product_name
FROM FW.AR_TRANS at
LEFT JOIN FW.ACCOUNT_RECEIVABLES ar
    ON at.CENTER = ar.CENTER
   AND at.ID = ar.ID
JOIN FW.PERSONS per
    ON per.CENTER = ar.CUSTOMERCENTER
   AND per.ID = ar.CUSTOMERID
   AND per.SEX != 'C'
JOIN FW.INVOICES inv
    ON inv.CENTER = at.REF_CENTER
   AND inv.ID = at.REF_ID
   AND at.REF_TYPE = 'INVOICE'
JOIN FW.INVOICELINES invl
    ON invl.CENTER = inv.CENTER
   AND invl.ID = inv.ID
JOIN FW.PRODUCTS p
    ON p.CENTER = invl.PRODUCTCENTER
   AND p.ID = invl.PRODUCTID
Where at.TRANS_TIME BETWEEN :time_from AND :time_to + (24*3600*1000)
  AND ar.CUSTOMERCENTER IN (:scope)
	AND at.text like 'App\ValidationDebtHandler::handleDebt%'
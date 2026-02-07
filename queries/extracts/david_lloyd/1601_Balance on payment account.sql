-- This is the version from 2026-02-05
--  
SELECT
ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
ar.balance,
art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
'revert incorrect file' AS "Text",
art.amount,
ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID    AS PaidBy,
art.text,
art.due_date,
art.unsettled_amount,
art.info,
longtodate(trans_time) 
       
       
      

FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons p
ON
    p.center = ar.customercenter
    and p.id = ar.customerid    	

JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID

WHERE
    ar.AR_TYPE = 4
  
  AND art.status IN ('OPEN','NEW')
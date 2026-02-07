-- This is the version from 2026-02-05
-- Kan ændres efter behov

SELECT 
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID, 
    (p.firstname||' '||p.lastname) as customer_name, 
    ar.BALANCE,
    eclub2.longToDate(ar.LAST_ENTRY_TIME),
	p.center as Center	
FROM 
    ACCOUNT_RECEIVABLES ar
JOIN 
    persons p
    ON 
    ar.customercenter = p.center 
    and ar.customerid = p.id 
JOIN
    PAYMENT_ACCOUNTS pa 
    ON 
    pa.center = ar.center 
    and pa.id = ar.id
WHERE
     ar.BALANCE <> 0 
and p.center in (131, 197, 202, 242, 270, 271)
  AND P.STATUS IN (:PersonStatus )
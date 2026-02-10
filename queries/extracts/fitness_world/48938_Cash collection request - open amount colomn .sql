-- The extract is extracted from Exerp on 2026-02-08
-- til open amount kolonne indtil bug er fikset
SELECT 
    per.center, 
    per.id, 
    per.SEX,
    --cc.AMOUNT as CC_AMOUNT, 
    ar.BALANCE as AR_BALANCE,
    r.RELATIVECENTER, r.RELATIVEID
FROM 
   CASHCOLLECTIONCASES cc 
JOIN 
    PERSONS per 
    ON 
    cc.PERSONCENTER = per.center 
    and cc.PERSONID = per.id 
JOIN 
    ACCOUNT_RECEIVABLES ar 
    ON 
    ar.CUSTOMERCENTER = per.center 
    and ar.CUSTOMERID = per.id 
LEFT JOIN 
    relatives r 
    ON 
    per.center    = r.center 
    and per.id    = r.id 
    and r.rtype = 12 
WHERE 
    cc.MISSINGPAYMENT = 1 
    and cc.CLOSED     = 0 
    and ar.AR_TYPE    in (4,5) 
    
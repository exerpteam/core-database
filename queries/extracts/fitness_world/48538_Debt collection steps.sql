-- The extract is extracted from Exerp on 2026-02-08
-- til at sammenligne med manuelle udtræk
SELECT DISTINCT ON (ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID, cc.amount, cc.CURRENTSTEP_DATE)
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid,
    ar.balance,
    cc.amount as cc_amount,
    CASE cc.CURRENTSTEP
        WHEN 1 THEN 'WAIT'
        WHEN 2 THEN 'Påmindelse 1'
        WHEN 3 THEN 'Påmindelse 2'
        WHEN 4 THEN 'Blokér medlemskab'
        WHEN 5 THEN 'Påmindelse 3'
        WHEN 6 THEN 'Request buyout'
        WHEN 7 THEN 'Ryk til ekstern'
    END AS DEBT_STEP,
    cc.CURRENTSTEP_DATE,
    cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
    cc.closed
FROM ECLUB2.ACCOUNT_RECEIVABLES ar
JOIN ECLUB2.CASHCOLLECTIONCASES cc ON
    ar.CUSTOMERCENTER = cc.PERSONCENTER
    AND ar.CUSTOMERID = cc.PERSONID
JOIN ECLUB2.PERSONS p ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
WHERE ar.BALANCE < 0
    AND cc.MISSINGPAYMENT = 1
    AND cc.CLOSED = 0
    AND p.status IN (1,3)
    AND p.center IN (:scope)
	AND cc.CURRENTSTEP IN (:G)
--  AND cc.CURRENTSTEP_DATE > '01.12.2021'
ORDER BY ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID, cc.amount, cc.CURRENTSTEP_DATE;

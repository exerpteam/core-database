-- This is the version from 2026-02-05
--  
SELECT
ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
art.AMOUNT,
longtodate(art.ENTRY_TIME) AS entrytime,
art.EMPLOYEECENTER||'emp'|| art.EMPLOYEEID AS employee,
art.DUE_DATE,
art.AMOUNT,
art.INFO,
art.TEXT,
art.COLLECTED,
-- art.STATUS,
art.UNSETTLED_AMOUNT
-- art.COLLECTED_AMOUNT
--act.info
FROM
ACCOUNT_RECEIVABLES ar
JOIN
AR_TRANS art
ON
art.center = ar.center
AND art.id = ar.id
JOIN
ACCOUNT_TRANS act
ON
art.REF_CENTER = act.CENTER
AND art.REF_ID = act.ID
AND art.REF_SUBID = act.SUBID
AND art.REF_TYPE = 'ACCOUNT_TRANS'
WHERE
ar.AR_TYPE = 6
and art.due_date >= :cutdate

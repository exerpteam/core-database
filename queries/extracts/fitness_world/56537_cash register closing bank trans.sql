-- This is the version from 2026-02-05
--  
SELECT
    crt.CRCENTER center_cashregister,
    sum(crt.amount)as "amount transfer to bank",
    'for perioden '||to_char(longtodate(:from_date),'dd-mm-yyyy')|| ' til '||to_char(longtodate(:to_date),'dd-mm-yyyy') as period 
    FROM
    CASHREGISTERREPORTS crr
JOIN CASHREGISTERTRANSACTIONS crt
ON
    crt.CRCENTER = crr.CENTER
AND crt.CRID = crr.ID
AND crt.CRSUBID = crr.SUBID
JOIN ACCOUNT_TRANS act
ON
    act.CENTER = crt.GLTRANSCENTER
AND act.ID = crt.GLTRANSID
AND act.SUBID = crt.GLTRANSSUBID
JOIN ACCOUNTS debAcc
ON
    debAcc.CENTER = act.DEBIT_ACCOUNTCENTER
AND debAcc.ID = act.DEBIT_ACCOUNTID
JOIN ACCOUNTS credAcc
ON
    credAcc.CENTER = act.CREDIT_ACCOUNTCENTER
AND credAcc.ID = act.CREDIT_ACCOUNTID
WHERE
   crt.CRCENTER in (:scope)
 and 
  crt.TRANSTIME between (:from_date) and (:to_date+86400000)
  AND crt.CRTTYPE IN (11,21)
group by
crt.crcenter

order by
crt.crcenter


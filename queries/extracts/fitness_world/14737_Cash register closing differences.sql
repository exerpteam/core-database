-- The extract is extracted from Exerp on 2026-02-08
-- Blocked for now - a revision is on it's way.
SELECT
    crt.CRCENTER center_cashregister,
    DECODE (crt.CRTTYPE, 10, 'cash adjustment during the day', 15,
'CREDIT_CARD_ADJUST', 16, 'closing cash adjust', 20, 'closing card
adjust','UNKNOWN') AS TRANSACTION_TYPE,
    CASE
        WHEN debAcc.GLOBALID = 'CASHREGISTER_DIFFERENCE'
        THEN '-'||''||crt.AMOUNT
        WHEN credAcc.GLOBALID = 'CASHREGISTER_DIFFERENCE'
        THEN '+'||''||crt.AMOUNT
        WHEN debAcc.GLOBALID = 'CASHREGISTER_BALANCE_2'
        THEN '+'||''||crt.AMOUNT
        WHEN credAcc.GLOBALID = 'CASHREGISTER_BALANCE_2'
        THEN '-'||''||crt.AMOUNT
        ELSE 'Unknown sign'||''||crt.AMOUNT
    END AS Difference,
    crt.CRID,
    crt.CRSUBID,
    longToDate(crt.TRANSTIME) as transaction_time,
    crt.COMENT
FROM
    FW.CASHREGISTERREPORTS crr
JOIN FW.CASHREGISTERTRANSACTIONS crt
ON
    crt.CRCENTER = crr.CENTER
AND crt.CRID = crr.ID
AND crt.CRSUBID = crr.SUBID
JOIN FW.ACCOUNT_TRANS act
ON
    act.CENTER = crt.GLTRANSCENTER
AND act.ID = crt.GLTRANSID
AND act.SUBID = crt.GLTRANSSUBID
JOIN FW.ACCOUNTS debAcc
ON
    debAcc.CENTER = act.DEBIT_ACCOUNTCENTER
AND debAcc.ID = act.DEBIT_ACCOUNTID
JOIN FW.ACCOUNTS credAcc
ON
    credAcc.CENTER = act.CREDIT_ACCOUNTCENTER
AND credAcc.ID = act.CREDIT_ACCOUNTID
WHERE
    crt.CRCENTER in (:scope)
  and crt.TRANSTIME between (:from_date) and (:to_date)
  AND crt.CRTTYPE IN (10,15,16,20)
order by
   crt.TRANSTIME,
   crt.crid


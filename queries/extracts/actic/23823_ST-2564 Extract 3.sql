-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    'DEBIT' KIND, act.*
FROM
    ACCOUNTS acc
join ACCOUNT_TRANS act on act.DEBIT_ACCOUNTCENTER = acc.CENTER and act.DEBIT_ACCOUNTID = acc.ID
WHERE
    acc.EXTERNAL_ID = '6387'
    and act.ENTRY_TIME > dateToLongC(to_char(exerpsysdate(), 'YYYYMMdd HH24:MI'),act.CENTER) 
union all 
SELECT
    'CREDIT' KIND, act.*
FROM
    ACCOUNTS acc
join ACCOUNT_TRANS act on act.CREDIT_ACCOUNTCENTER = acc.CENTER and act.CREDIT_ACCOUNTID = acc.ID
WHERE
    acc.EXTERNAL_ID = '6387'    
    and act.ENTRY_TIME > dateToLongC(to_char(exerpsysdate(), 'YYYYMMdd HH24:MI'),act.CENTER) 
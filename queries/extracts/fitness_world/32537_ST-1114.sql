-- This is the version from 2026-02-05
--  
SELECT
--    SUM(
--        CASE
--            WHEN CREDIT.GLOBALID = 'WRITTEN_OFF_SUBSCRIPT_TYPE_1'
--            THEN -1 * act.amount
--            ELSE act.amount
--        END) amount,
--    SUM(
--        CASE
--            WHEN CREDIT.GLOBALID = 'WRITTEN_OFF_SUBSCRIPT_TYPE_1'
--            THEN -1 * act.amount
--            ELSE 0
--        END) credit,
--    SUM(
--        CASE
--            WHEN CREDIT.GLOBALID = 'WRITTEN_OFF_SUBSCRIPT_TYPE_1'
--            THEN 0
--            ELSE act.amount
--        END) debit,                
--    COUNT(1) cnt
        --'select * from ACCOUNT_TRANS act where act.center = ' || act.CENTER || ' and act.id = ' || act.ID || ' and act.SUBID= ' || act.SUBID || ';'  debug,
        CASE
            WHEN CREDIT.GLOBALID = $$ACCONT_GLOBAL_ID$$
            THEN act.amount
            ELSE null
        END credit,
        
        CASE
            WHEN CREDIT.GLOBALID = $$ACCONT_GLOBAL_ID$$
            THEN null
            ELSE act.amount
        END debit,
        art.AMOUNT AR_TRANS_AMOUNT,
        act.AMOUNT AC_TRANS_AMOUNT,        
        ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
        CREDIT.GLOBALID CREDIT_ACCOUNT,
        DEBIT.GLOBALID DEBIT_ACCOUNT,
        exerpro.longToDate(art.TRANS_TIME) trans_time,
        art.TEXT AR_TEXT,
        act.TEXT AC_TRANS_TEXT,
        nvl2(cnl.CENTER,'CREDIT_NOTE','TRANSACTION') type
FROM
    ACCOUNT_TRANS act
JOIN
    ACCOUNTS DEBIT
ON
    DEBIT.CENTER = act.DEBIT_ACCOUNTCENTER
    AND DEBIT.ID = act.DEBIT_ACCOUNTID
JOIN
    ACCOUNTS CREDIT
ON
    CREDIT.CENTER = act.CREDIT_ACCOUNTCENTER
    AND CREDIT.ID = act.CREDIT_ACCOUNTID
LEFT JOIN
    CREDIT_NOTE_LINES cnl
ON
    cnl.ACCOUNT_TRANS_CENTER = act.CENTER
    AND cnl.ACCOUNT_TRANS_ID = act.ID
    AND cnl.ACCOUNT_TRANS_SUBID = act.SUBID
LEFT JOIN
    AR_TRANS art
ON
    (
        art.REF_TYPE = 'CREDIT_NOTE'
        AND art.REF_CENTER = cnl.CENTER
        AND art.REF_ID = cnl.ID)
    OR (
        art.REF_TYPE = 'ACCOUNT_TRANS'
        AND art.REF_CENTER = act.CENTER
        AND art.REF_ID = act.ID
        AND art.REF_SUBID = act.SUBID)
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
WHERE
    (
        DEBIT.GLOBALID = $$ACCONT_GLOBAL_ID$$
        OR CREDIT.GLOBALID = $$ACCONT_GLOBAL_ID$$)
    AND act.CENTER in ($$scope$$)
--    and act.AMOUNT = 234.07
--    and not (DEBIT.GLOBALID = 'AR_PAYMENT_PERSONS' or CREDIT.GLOBALID = 'AR_PAYMENT_PERSONS') 
--    and ar.CUSTOMERCENTER = 608 and ar.CUSTOMERID = 3781
--    AND act.TRANS_TIME BETWEEN exerpro.dateToLong('2016-02-01' || ' 00:00') AND exerpro.dateToLong('2016-02-29' || ' 00:00') 
AND act.TRANS_TIME BETWEEN $$fromDate$$ AND $$toDate$$
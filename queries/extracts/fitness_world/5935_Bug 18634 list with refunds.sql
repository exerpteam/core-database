-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.FIRSTNAME || ' ' || p.LASTNAME          AS full_name,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS pid,
    pa.BANK_REGNO,
    pa.BANK_ACCNO,
    --MAX(INV_AMOUNT.renewal) renewal_amount,
    ar.BALANCE current_balance,
    /* SUM(art.AMOUNT) wrongly_deducted,*/
    ar.BALANCE - NVL(INV_AMOUNT.renewal, 0) refund,
    ar.BALANCE - (ar.BALANCE - NVL(INV_AMOUNT.renewal, 0)) balance_after_refund
    
    --,SUM(art.AMOUNT)-((-INV_AMOUNT.renewal) + ar.BALANCE) as DIFF 
    
FROM
    FW.ACCOUNT_RECEIVABLES ar
JOIN FW.AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND ar.AR_TYPE = 4
JOIN FW.persons p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4
LEFT JOIN
    (
        SELECT
            renew_art.center,
            renew_art.id,
            SUM(renew_art.amount) renewal
        FROM
            FW.AR_TRANS renew_art
        WHERE
            renew_art.EMPLOYEECENTER IS NULL
            AND renew_art.ENTRY_TIME > datetolong('2010-10-19 00:00')
            AND renew_art.text LIKE ('%Auto Renewal%')
        GROUP BY
            renew_art.center,
            renew_art.id
    )
    INV_AMOUNT
ON
    INV_AMOUNT.center = ar.center
    AND INV_AMOUNT.id = ar.id
LEFT JOIN FW.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN FW.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    art.ENTRY_TIME >= 1286748000000
    AND art.ENTRY_TIME < 1287007200000
    AND art.EMPLOYEECENTER = 100
    AND art.EMPLOYEEID = 1

GROUP BY
    p.FIRSTNAME || ' ' || p.LASTNAME,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID,
    ar.BALANCE,
    pa.BANK_REGNO,
    pa.BANK_ACCNO,
    ar.BALANCE, 
    INV_AMOUNT.renewal

    HAVING
    SUM(art.AMOUNT) > 0 
    and ar.BALANCE - NVL(INV_AMOUNT.renewal, 0) > 0
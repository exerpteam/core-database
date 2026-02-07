WITH
    params AS MATERIALIZED
    (   SELECT
            id                                                                          AS centerid,
            datetolongc(TO_CHAR(to_date(:Fromdate,'YYYY-MM-DD'),'YYYY-MM-DD'),id) ::bigint AS
            from_epoch,
            datetolongc(TO_CHAR(to_date(:Todate,'YYYY-MM-DD'),'YYYY-MM-DD'),id) ::bigint + 24*3600
            *1000            AS to_epoch,
            :Fromdate ::DATE AS from_date,
            :Todate ::  DATE AS to_date,
            shortname        AS shortname
        FROM
            centers
        WHERE
            id IN (:scope)
    )
SELECT
    tr.center,
    params.shortname,
    '3. Arrears payments, Refunds and DDIC' AS reportgroup,
    'CASH to PAYMENT account'               AS subgroup,
    ar.customercenter||'p'||ar.customerid   AS member_id,
    art.text                                AS description,
    art.amount                              AS amount,
    longtodatec(art.trans_time, art.center) AS DATETIME
FROM
    ACCOUNT_TRANS tr
JOIN
    ACCOUNTS credit
ON
    tr.CREDIT_ACCOUNTCENTER = credit.center
AND tr.CREDIT_ACCOUNTID = credit.id
JOIN
    ACCOUNTS debit
ON
    tr.DEBIT_ACCOUNTCENTER = debit.center
AND tr.DEBIT_ACCOUNTID = debit.id
JOIN
    AR_TRANS art
ON
    art.REF_TYPE = 'ACCOUNT_TRANS'
AND art.REF_CENTER = tr.CENTER
AND art.REF_ID = tr.ID
AND art.REF_SUBID = tr.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
AND ar.id = art.id
AND ar.AR_TYPE IN (1,4)
JOIN
    params
ON
    tr.center = params.centerid
WHERE
    tr.TRANS_TIME >= params.from_epoch
AND tr.TRANS_TIME < params.to_epoch
AND credit.GLOBALID IN ('AR_PAYMENT_PERSONS')
AND debit.GLOBALID IN ('AR_CASH')
AND art.text = 'Payment into account'
AND art.amount > 0
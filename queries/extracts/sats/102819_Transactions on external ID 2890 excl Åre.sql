WITH
    params AS MATERIALIZED
    (   SELECT
            CAST(datetolong(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS
            fromDateLong,
            CAST(datetolong(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD'
            )) AS BIGINT) AS toDateLong,
            c.id          AS center_id,
            c.name        AS center_name
        FROM
            centers c
        WHERE
            c.country = 'SE'
        AND c.id != 584
    )
    ,
    sub_art AS MATERIALIZED
    (   SELECT
            center,
            id,
            subid,
            trans_type,
            trans_time,
            entry_time,
            amount,
            debit_accountcenter,
            debit_accountid,
            credit_accountcenter,
            credit_accountid,
            TEXT,
            aggregated_transaction_center,
            aggregated_transaction_id
        FROM
            ACCOUNT_TRANS act
        JOIN
            params par
        ON
            par.center_id = act.center
        WHERE
            act.TRANS_TIME >= par.fromDateLong
        AND act.TRANS_TIME < par.toDateLong
    )
SELECT 
    deb.external_id  AS debitexternal,
    cred.external_id AS creditexternal,
    act.CENTER,
    act.DEBIT_ACCOUNTCENTER                              accountcenter,
    act.DEBIT_ACCOUNTID                                      accountid,
    act.AMOUNT                                                  amount,
    TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD')                         book_date,
    longtodate(act.entry_TIME)                                                entrytime,
    act.text                                                                  AS TEXT,
    act.aggregated_transaction_center ||'agt'|| act.aggregated_transaction_id AS aggrtransid,
    CASE
        WHEN act.trans_type = 2
        THEN ar.customercenter ||'p'|| ar.customerid
        WHEN act.trans_type = 5
        THEN credl.person_center ||'p'|| credl.person_id
        ELSE invl.person_center ||'p'|| invl.person_id
    END AS Memberid,
    CASE act.TRANS_TYPE
        WHEN 1
        THEN 'GeneralLedger'
        WHEN 2
        THEN 'AccountReceivable'
        WHEN 3
        THEN 'AccountPayable'
        WHEN 4
        THEN 'InvoiceLine'
        WHEN 5
        THEN 'CreditNoteLine'
        WHEN 6
        THEN 'BillLine'
        ELSE 'Undefined'
    END                                          AS TRANS_TYPE,
    act.center||'acc'||act.id ||'tr'|| act.subid AS Transid
FROM
    sub_art act
JOIN
    ACCOUNTS deb
ON
    act.debIT_ACCOUNTCENTER = deb.CENTER
AND act.debIT_ACCOUNTID = deb.ID
JOIN
    ACCOUNTS cred
ON
    act.CREDIT_ACCOUNTCENTER = cred.CENTER
AND act.CREDIT_ACCOUNTID = cred.ID
LEFT JOIN
    ar_trans art
ON
    art.ref_center = act.center
AND art.ref_id = act.id
AND art.ref_subid = act.subid
AND art.ref_type = 'ACCOUNT_TRANS'
LEFT JOIN
    account_receivables ar
ON
    art.center = ar.center
AND art.id = ar.id
LEFT JOIN
    invoice_lines_mt invl
ON
    invl.account_trans_center = act.center
AND invl.account_trans_id = act.id
AND invl.account_trans_subid = act.subid
LEFT JOIN
    credit_note_lines_mt credl
ON
    credl.account_trans_center = act.center
AND credl.account_trans_id = act.id
AND credl.account_trans_subid = act.subid
WHERE
    (
        deb.external_id = '2890')
OR
    (
        cred.external_id = '2890')
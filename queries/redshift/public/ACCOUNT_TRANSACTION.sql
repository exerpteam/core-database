SELECT
    center||'acc'||id||'tr'||subid AS "ID",
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
    END                                           AS "TYPE",
    entry_time                                  AS "ENTRY_DATETIME",
    trans_time                                  AS "TRANSACTION_DATETIME",
    amount                                        AS "AMOUNT",
    debit_accountcenter||'acc'||debit_accountid   AS "DEBIT_ACCOUNT_ID",
    credit_accountcenter||'acc'||credit_accountid AS "CREDIT_ACCOUNT_ID",
    text                                          AS "TEXT",
    case when transferred = 1 then true else false end as "TRANSFERRED",
    CASE
        WHEN AGGREGATED_TRANSACTION_CENTER IS NOT NULL
        THEN AGGREGATED_TRANSACTION_CENTER||'agt'||AGGREGATED_TRANSACTION_ID
        ELSE NULL
    END        AS "AGGREGATED_TRANSACTION_ID",
    center                                        AS "CENTER_ID",
    entry_time                                    AS "ETS"
FROM
    account_trans act

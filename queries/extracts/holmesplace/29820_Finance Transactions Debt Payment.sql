-- The extract is extracted from Exerp on 2026-02-08
-- look for text
API Register remaining money from payment request
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            dateToLongC(TO_CHAR(cast(:fromDate as date), 'YYYY-MM-dd HH24:MI'), c.id)                 AS FromDate,
            (dateToLongC(TO_CHAR(cast(:toDate as date), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS ToDate
        FROM
            centers c
    )
SELECT
    CASE
        WHEN p.CENTER IS NOT NULL
        THEN p.CENTER || 'p' || p.ID
        ELSE NULL
    END AS "Person ID",
    -- payer id --
    (
        CASE
            WHEN t1.TypeT1 = 'Account receivables'
            THEN p.CENTER || 'p' || p.ID
            WHEN t1.TypeT1 = 'Credit note line'
            THEN t1.CN_PAYER
            WHEN t1.TypeT1 = 'Invoice line'
            THEN t1.IL_PAYER
            ELSE NULL
        END)                             AS "Payer ID",
p.external_id,
    TO_CHAR((p.BIRTHDATE), 'YYYY-MM-dd') AS "Date of  birth",
    t1.Bookdate                          AS "Book date",
    (
        CASE
            WHEN t1.TypeT1 = 'Invoice line'
            THEN t1.IL_TEXT
            WHEN t1.TypeT1 = 'Credit note line'
            THEN t1.CN_TEXT
            ELSE t1.Text
        END)               AS "Text",
    t1.Amount              AS "Amount",
    t1.Type_financeaccount AS "Type Financeaccount",
    t1.ExternalId          AS "ExternalId",
    t1.Account             AS "Account",
    t1.TypeT1              AS "Type",
    t1.Entrytime           AS "Entry time",
    t1.Aggrtransid         AS "Aggr. trans. id",
    t1.Centername          AS "Center name"
FROM
    (
        SELECT
            find_trans.CENTER || 'act' ||find_trans.ID || 'id' || find_trans.SUBID      AS ACTTRANS,
            TO_CHAR(longtodatec(find_trans.TRANS_TIME,find_trans.CENTER), 'YYYY-MM-dd') AS Bookdate
            ,
            find_trans.TEXT AS Text,
            art_il.text     AS IL_TEXT,
            art_il_cn.text  AS CN_TEXT,
            find_trans.ExternalId,
            art.REF_TYPE,
            (
                CASE find_trans.credit_or_debit
                    WHEN 'Credit'
                    THEN -find_trans.AMOUNT
                    WHEN 'Debit'
                    THEN find_trans.AMOUNT
                    ELSE find_trans.AMOUNT
                END) AS Amount,
            (
                CASE find_trans.credit_or_debit
                    WHEN 'Credit'
                    THEN 'Credit'
                    WHEN 'Debit'
                    THEN 'Debit'
                    ELSE 'error'
                END) AS Type_financeaccount,
            find_trans.Account,
            vatTran.AMOUNT AS VAT,
            vatType.NAME   AS VATtype,
            (
                CASE
                    WHEN find_trans.TRANS_TYPE=1
                    THEN 'General ledger'
                    WHEN find_trans.TRANS_TYPE=2
                    THEN 'Account receivables'
                    WHEN find_trans.TRANS_TYPE=3
                    THEN 'Account payables'
                    WHEN find_trans.TRANS_TYPE=4
                    THEN 'Invoice line'
                    WHEN find_trans.TRANS_TYPE=5
                    THEN 'Credit note line'
                    WHEN find_trans.TRANS_TYPE=6
                    THEN 'Bill line'
                    ELSE 'Unknown'
                END)                                                                      AS TypeT1,
            TO_CHAR(longtodatec(find_trans.ENTRY_TIME,find_trans.CENTER), 'YYYY-MM-dd HH24:MI') AS
            Entrytime,
            (
                CASE
                    WHEN find_trans.AGGREGATED_TRANSACTION_CENTER IS NOT NULL
                    THEN find_trans.AGGREGATED_TRANSACTION_CENTER || 'agt' ||
                        find_trans.AGGREGATED_TRANSACTION_ID
                    ELSE NULL
                END) AS Aggrtransid,
            c.NAME   AS Centername,
            (
                CASE
                    WHEN find_trans.TRANS_TYPE=2
                    THEN ar.CUSTOMERCENTER
                    WHEN find_trans.TRANS_TYPE=4
                    THEN il.PERSON_CENTER
                    WHEN find_trans.TRANS_TYPE=5
                    THEN cn.PERSON_CENTER
                    ELSE NULL
                END) PersonCenter,
            (
                CASE
                    WHEN find_trans.TRANS_TYPE=2
                    THEN ar.CUSTOMERID
                    WHEN find_trans.TRANS_TYPE=4
                    THEN il.PERSON_ID
                    WHEN find_trans.TRANS_TYPE=5
                    THEN cn.PERSON_ID
                    ELSE NULL
                END) PersonId,
            (
                CASE
                    WHEN find_trans.TRANS_TYPE=4
                    AND i.PAYER_CENTER IS NOT NULL
                    THEN i.PAYER_CENTER || 'p' || i.PAYER_ID
                    ELSE NULL
                END) AS IL_PAYER,
            (
                CASE
                    WHEN find_trans.TRANS_TYPE=5
                    AND creditnote.PAYER_CENTER IS NOT NULL
                    THEN creditnote.PAYER_CENTER || 'p' || creditnote.PAYER_ID
                    WHEN find_trans.TRANS_TYPE=5
                    AND creditnote.PAYER_CENTER IS NULL
                    THEN cn.PERSON_CENTER || 'p' || cn.PERSON_ID
                    ELSE NULL
                END) AS CN_PAYER
        FROM
            (
                SELECT
                    act.*,
                    creditAccount.EXTERNAL_ID AS ExternalId,
                    creditAccount.NAME || ' (' || creditAccount.CENTER || 'acc' || creditAccount.ID
                    || ')'   AS Account,
                    'Credit' AS credit_or_debit
                FROM
                    ACCOUNT_TRANS act
                JOIN
                    params
                ON
                    params.id = act.center
                LEFT JOIN
                    ACCOUNTS creditAccount
                ON
                    creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER
                AND creditAccount.ID = act.CREDIT_ACCOUNTID
                WHERE
                    act.TRANS_TIME >= params.fromDate
                AND act.TRANS_TIME < params.toDate
                AND act.CENTER IN (:Scope)
                AND act.trans_type IN (2)
                AND act.MAIN_TRANSCENTER IS NULL
                UNION ALL
                SELECT
                    act.*,
                    debitAccount.EXTERNAL_ID AS ExternalId,
                    debitAccount.NAME || ' (' || debitAccount.CENTER || 'acc' || debitAccount.ID ||
                    ')'     AS Account,
                    'Debit' AS credit_or_debit
                FROM
                    ACCOUNT_TRANS act
                JOIN
                    params
                ON
                    params.id = act.center
                LEFT JOIN
                    ACCOUNTS debitAccount
                ON
                    debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER
                AND debitAccount.ID = act.DEBIT_ACCOUNTID
                WHERE
                    act.TRANS_TIME >= params.fromDate
                AND act.TRANS_TIME < params.toDate
                AND act.CENTER IN (:Scope)
                AND act.trans_type IN (2)
                AND act.MAIN_TRANSCENTER IS NULL ) find_trans
        JOIN
            CENTERS c
        ON
            c.ID = find_trans.CENTER
        LEFT JOIN
            ACCOUNT_TRANS vatTran
        ON
            vatTran.MAIN_TRANSCENTER = find_trans.CENTER
        AND vatTran.MAIN_TRANSID = find_trans.ID
        AND vatTran.MAIN_TRANSSUBID = find_trans.SUBID
        LEFT JOIN
            VAT_TYPES vatType
        ON
            vatType.CENTER = vatTran.VAT_TYPE_CENTER
        AND vatType.ID = vatTran.VAT_TYPE_ID
        LEFT JOIN
            INVOICE_LINES_MT il
        ON
            il.ACCOUNT_TRANS_CENTER = find_trans.CENTER
        AND il.ACCOUNT_TRANS_ID = find_trans.ID
        AND il.ACCOUNT_TRANS_SUBID = find_trans.SUBID
        AND find_trans.TRANS_TYPE=4
        LEFT JOIN
            HP.INVOICES i
        ON
            i.CENTER = il.CENTER
        AND i.ID = il.ID
        LEFT JOIN
            CREDIT_NOTE_LINES_MT cn
        ON
            cn.ACCOUNT_TRANS_CENTER = find_trans.CENTER
        AND cn.ACCOUNT_TRANS_ID = find_trans.ID
        AND cn.ACCOUNT_TRANS_SUBID = find_trans.SUBID
        AND find_trans.TRANS_TYPE=5
        LEFT JOIN
            CREDIT_NOTES creditnote
        ON
            creditnote.CENTER = cn.CENTER
        AND creditnote.ID = cn.ID
        LEFT JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = find_trans.CENTER
        AND art.REF_ID = find_trans.ID
        AND art.REF_SUBID = find_trans.SUBID
        AND find_trans.TRANS_TYPE=2
        AND art.REF_TYPE = 'ACCOUNT_TRANS'
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
        AND ar.ID = art.ID
        LEFT JOIN
            HP.AR_TRANS art_il
        ON
            art_il.REF_CENTER = i.CENTER
        AND art_il.REF_ID = i.ID
        AND art_il.REF_TYPE = 'INVOICE'
        LEFT JOIN
            HP.AR_TRANS art_il_cn
        ON
            art_il_cn.REF_CENTER = creditnote.CENTER
        AND art_il_cn.REF_ID = creditnote.ID
        AND art_il_cn.REF_TYPE = 'CREDIT_NOTE'
        ORDER BY
            find_trans.TRANS_TIME ) t1
LEFT JOIN
    PERSONS p
ON
    t1.PersonCenter = p.CENTER
AND t1.PersonId = p.ID
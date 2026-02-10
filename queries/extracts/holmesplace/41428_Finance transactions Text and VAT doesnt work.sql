-- The extract is extracted from Exerp on 2026-02-08
-- I want the Finance Transactions report with text from invoice and credit note lines

WITH
    params AS
    (
        SELECT
            c.id,
            dateToLongC(TO_CHAR(cast($$fromDate$$ as date), 'YYYY-MM-DD HH24:MI'), c.id)                   AS FromDate,
            (dateToLongC(TO_CHAR(cast($$toDate$$ as date), 'YYYY-MM-DD HH24:MI'), c.id)+ 86400 * 1000)-1 AS ToDate
        FROM
            centers c
    )
SELECT
    (
        CASE
            WHEN p.CENTER IS NOT NULL
            THEN p.CENTER || 'p' || p.ID
            ELSE NULL
        END)            AS "Person ID",
    p.BIRTHDATE         AS "Date of  birth",
    p.FIRSTNAME         AS "First name",
    P.LASTNAME          AS "Surname",
    t1.Bookdate         AS "Book date",
    (
        CASE
            WHEN t1.TypeT1 = 'Invoice line'
            THEN il_TEXT
            WHEN t1.TypeT1 = 'Credit note line'
            THEN cn_TEXT
            ELSE t1.Text
        END)               AS "Text",
    t1.DebitExternalId  AS "Debit",
    t1.Amount           AS "Amount",
    t1.CreditExternalId AS "Credit",
    t1.DebitAccount     AS "Debit Account",
    t1.CreditAccount    AS "Credit Account",
    t1.VAT              AS "VAT",
    t1.VATtype          AS "VAT type",
    t1.TypeT1           AS "Type",
    t1.Entrytime        AS "Entry time",
    t1.Aggrtransid      AS "Aggr. trans. id",
    t1.Centername       AS "Center name"
FROM
    (
        SELECT
            act.CENTER || 'act' ||act.ID || 'id' || act.SUBID                                      AS ACTTRANS,
            TO_CHAR(longtodatec(act.ENTRY_TIME,act.CENTER), 'YYYY-MM-dd HH24:MI')                  AS Bookdate,
            
			act.TEXT  AS Text,
            debitAccount.EXTERNAL_ID   AS DebitExternalId,
            act.AMOUNT            AS Amount,
            creditAccount.EXTERNAL_ID   AS CreditExternalId,
            debitAccount.NAME || ' (' || debitAccount.CENTER || 'acc' || debitAccount.ID || ')'    AS DebitAccount,
            creditAccount.NAME || ' (' || creditAccount.CENTER || 'acc' || creditAccount.ID || ')' AS CreditAccount,
            vatTran.AMOUNT           AS VAT,
            vatType.NAME            AS VATtype,
            (
                CASE
                    WHEN act.TRANS_TYPE=1
                    THEN 'General ledger'
                    WHEN act.TRANS_TYPE=2
                    THEN 'Account receivables'
                    WHEN act.TRANS_TYPE=3
                    THEN 'Account payables'
                    WHEN act.TRANS_TYPE=4
                    THEN 'Invoice line'
                    WHEN act.TRANS_TYPE=5
                    THEN 'Credit note line'
                    WHEN act.TRANS_TYPE=6
                    THEN 'Bill line'
                    ELSE 'Unknown'
                END)        AS TypeT1,
            TO_CHAR(longtodatec(act.ENTRY_TIME,act.CENTER), 'YYYY-MM-dd HH24:MI') AS Entrytime,
            (
                CASE
                    WHEN act.AGGREGATED_TRANSACTION_CENTER IS NOT NULL
                    THEN act.AGGREGATED_TRANSACTION_CENTER || 'agt' || act.AGGREGATED_TRANSACTION_ID
                    ELSE NULL
                END) AS Aggrtransid,
            	c.NAME   AS Centername,
            (
                CASE
                    WHEN act.TRANS_TYPE=2
                    THEN ar.CUSTOMERCENTER
                    WHEN act.TRANS_TYPE=4
                    THEN il.PERSON_CENTER
                    WHEN act.TRANS_TYPE=5
                    THEN cn.PERSON_CENTER
                    ELSE NULL
                END) PersonCenter,
            (
                CASE
                    WHEN act.TRANS_TYPE=2
                    THEN ar.CUSTOMERID
                    WHEN act.TRANS_TYPE=4
                    THEN il.PERSON_ID
                    WHEN act.TRANS_TYPE=5
                    THEN cn.PERSON_ID
                    ELSE NULL
                END) PersonId ,
            ar.*
        FROM
            ACCOUNT_TRANS act
        JOIN
            CENTERS c
        ON
            c.ID = act.CENTER
        LEFT JOIN
            ACCOUNTS creditAccount
        ON
            creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER
            AND creditAccount.ID = act.CREDIT_ACCOUNTID
        LEFT JOIN
            ACCOUNTS debitAccount
        ON
            debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER
            AND debitAccount.ID = act.DEBIT_ACCOUNTID
        LEFT JOIN
            ACCOUNT_TRANS vatTran
        ON
            vatTran.MAIN_TRANSCENTER = act.CENTER
            AND vatTran.MAIN_TRANSID = act.ID
            AND vatTran.MAIN_TRANSSUBID = act.SUBID
        LEFT JOIN
            VAT_TYPES vatType
        ON
            vatType.CENTER = vatTran.VAT_TYPE_CENTER
            AND vatType.ID = vatTran.VAT_TYPE_ID
        LEFT JOIN
            INVOICE_LINES_MT il
        ON
            il.ACCOUNT_TRANS_CENTER = act.CENTER
            AND il.ACCOUNT_TRANS_ID = act.ID
            AND il.ACCOUNT_TRANS_SUBID = act.SUBID
            AND act.TRANS_TYPE=4
		LEFT JOIN
            HP.INVOICES i
        ON
            i.CENTER = il.CENTER
            AND i.ID = il.ID


        LEFT JOIN
            CREDIT_NOTE_LINES_MT cn
        ON
            cn.ACCOUNT_TRANS_CENTER = act.CENTER
            AND cn.ACCOUNT_TRANS_ID = act.ID
            AND cn.ACCOUNT_TRANS_SUBID = act.SUBID
            AND act.TRANS_TYPE=5
LEFT JOIN
            CREDIT_NOTES creditnote
        ON
            creditnote.CENTER = cn.CENTER
            AND creditnote.ID = cn.ID


        LEFT JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = act.CENTER
            AND art.REF_ID = act.ID
            AND art.REF_SUBID = act.SUBID
            AND act.TRANS_TYPE=2
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
        JOIN
            params
        ON
            params.id = act.center
        WHERE
            act.TRANS_TIME >= params.fromDate
            AND act.TRANS_TIME < params.toDate
            AND act.CENTER IN ($$Scope$$)
            AND act.MAIN_TRANSCENTER IS NULL
        ORDER BY
            act.TRANS_TIME ) t1
LEFT JOIN
    PERSONS p
ON
    t1.PersonCenter = p.CENTER
    AND t1.PersonId = p.ID


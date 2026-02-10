-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/issues/EC-8389
WITH
    params AS materialized
    (
        SELECT
            c.id,
            c.shortname AS Centername,
            CAST(dateToLongC(TO_CHAR(CAST($$from_date$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS
            BIGINT) AS FromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$to_date$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400
            * 1000) AS BIGINT)-1 AS ToDate
        FROM
            centers c
        WHERE
            c.ID IN ($$Scope$$)
    )
SELECT
    "Book date",
    "Text",
    "Debit Account",
    "Debit",
    "Credit",
    "Credit Account",
    "Debit Account Name",
    "Credit Account Name",
    "VAT",
    "VAT type",
    "Type",
    "Entry time",
    "Aggr. trans. id",
    "Invoice",
    "Member",
    "Center name",
    ce_debit.name AS "Debit Center",
    ce_credit.name AS "Credit Center",
    "Info",
    CASE INFO_TYPE WHEN 1 THEN 'Legacy' WHEN 2 THEN 'DataConversion' WHEN 3 THEN 'EFT-File' WHEN 4 THEN 'Debt collection-File' 
          WHEN 5 THEN 'ARReason' WHEN 6 THEN 'CashRegister' WHEN 7 THEN 'OtherGL' WHEN 8 THEN 'API' WHEN 9 THEN 'CreditCard' WHEN 10 THEN 'VoucherRegistration' WHEN 11 THEN 'AccountReceivableOwner' WHEN 12 THEN 'CashRegisterManual' 
          WHEN 13 THEN 'Inventory' WHEN 14 THEN 'GiftCard' WHEN 15 THEN 'Delivery' WHEN 16 THEN 'OwnerManualPaymentOfRequest' 
          WHEN 17 THEN 'UnplacedPayment' ELSE 'Undefined' 
    END AS "Info Type",
    "Account transaction id",
    "VAT transaction id",
    staff.fullname AS "Employee Name"
FROM
    (
        SELECT
            TO_CHAR(longtodatec(find_trans.TRANS_TIME,find_trans.CENTER), 'YYYY-MM-dd') AS
            "Book date",
            find_trans.TEXT                                                   AS "Text",
            find_trans.debit_accountcenter||'acc'||find_trans.debit_accountid AS "Debit Account",
            CASE find_trans.credit_or_debit
                WHEN 'Debit'
                THEN find_trans.AMOUNT
                ELSE NULL
            END AS "Debit",
            CASE find_trans.credit_or_debit
                WHEN 'Credit'
                THEN -find_trans.AMOUNT
                ELSE NULL
            END                                                                 AS "Credit",
            find_trans.credit_accountcenter||'acc'||find_trans.credit_accountid AS "Credit Account"
            ,
            CASE find_trans.credit_or_debit
                WHEN 'Debit'
                THEN find_trans.Account
                WHEN 'Credit'
                THEN find_trans.ReverseAccount
                ELSE NULL
            END AS "Debit Account Name",
            CASE find_trans.credit_or_debit
                WHEN 'Credit'
                THEN find_trans.Account
                WHEN 'Debit'
                THEN find_trans.ReverseAccount
                ELSE NULL
            END            AS "Credit Account Name",
            vatTran.AMOUNT AS "VAT",
            vatType.NAME   AS "VAT type",
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
            END                                                                           AS "Type",
            TO_CHAR(longtodatec(find_trans.ENTRY_TIME,find_trans.CENTER), 'YYYY-MM-dd HH24:MI') AS
            "Entry time",
            CASE
                WHEN find_trans.AGGREGATED_TRANSACTION_CENTER IS NOT NULL
                THEN find_trans.AGGREGATED_TRANSACTION_CENTER || 'agt' ||
                    find_trans.AGGREGATED_TRANSACTION_ID
                ELSE NULL
            END AS "Aggr. trans. id",
            CASE
                WHEN find_trans.TRANS_TYPE=4
                THEN inv.center||'inv'||inv.id
                WHEN find_trans.TRANS_TYPE=5
                THEN cre.center||'cred'||cre.id
            END AS "Invoice",
            CASE
                WHEN find_trans.TRANS_TYPE=2
                THEN ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID
                WHEN find_trans.TRANS_TYPE=4
                THEN il.PERSON_CENTER||'p'||il.PERSON_ID
                WHEN find_trans.TRANS_TYPE=5
                THEN cn.PERSON_CENTER||'p'||cn.PERSON_ID
                ELSE NULL
            END "Member",
            params.CenterName                                                      AS "Center name",
            find_trans.info                                                        AS "Info",
            find_trans.info_type,
            find_trans.CENTER || 'acc' ||find_trans.ID || 'tr' || find_trans.SUBID AS
            "Account transaction id",
            vatTran.CENTER || 'acc' ||vatTran.ID || 'tr' || vatTran.SUBID AS "VAT transaction id",
            CASE
                WHEN find_trans.TRANS_TYPE=4
                THEN inv.employee_center
                WHEN find_trans.TRANS_TYPE=5
                THEN cre.employee_center
            END AS "Employee_Center",
            CASE
                WHEN find_trans.TRANS_TYPE=4
                THEN inv.employee_id
                WHEN find_trans.TRANS_TYPE=5
                THEN cre.employee_id
            END AS "Employee_ID",
            find_trans.DEBIT_ACCOUNTCENTER,
            find_trans.CREDIT_ACCOUNTCENTER
        FROM
            (
                SELECT
                    act.*,
                    creditAccount.NAME || ' (' || creditAccount.globalid || ')' AS Account,
                    debt_Acc.NAME || ' (' || debt_Acc.EXTERNAL_ID || ')'        AS ReverseAccount,
                    'Credit'                                                    AS credit_or_debit
                FROM
                    ACCOUNT_TRANS act
                JOIN
                    params
                ON
                    params.id = act.center
                JOIN
                    ACCOUNTS creditAccount
                ON
                    creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER
                AND creditAccount.ID = act.CREDIT_ACCOUNTID
                LEFT JOIN
                    ACCOUNTS debt_Acc
                ON
                    debt_Acc.CENTER = act.DEBIT_ACCOUNTCENTER
                AND debt_Acc.ID = act.DEBIT_ACCOUNTID
                WHERE
                    act.TRANS_TIME >= params.fromDate
                AND act.TRANS_TIME < params.toDate
                AND act.MAIN_TRANSCENTER IS NULL
                AND creditAccount.globalid = 'AR_CASH'
                UNION ALL
                SELECT
                    act.*,
                    debitAccount.NAME || ' (' || debitAccount.globalid || ')' AS Account,
                    cred_Acc.NAME || ' (' || cred_Acc.EXTERNAL_ID || ')'      AS ReverseAccount,
                    'Debit'                                                   AS credit_or_debit
                FROM
                    ACCOUNT_TRANS act
                JOIN
                    params
                ON
                    params.id = act.center
                JOIN
                    ACCOUNTS debitAccount
                ON
                    debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER
                AND debitAccount.ID = act.DEBIT_ACCOUNTID
                LEFT JOIN
                    ACCOUNTS cred_Acc
                ON
                    cred_Acc.CENTER = act.CREDIT_ACCOUNTCENTER
                AND cred_Acc.ID = act.CREDIT_ACCOUNTID
                WHERE
                    act.TRANS_TIME >= params.fromDate
                AND act.TRANS_TIME < params.toDate
                AND act.MAIN_TRANSCENTER IS NULL
                AND debitAccount.globalid = 'AR_CASH' ) find_trans
        JOIN
            params
        ON
            params.ID = find_trans.CENTER
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
            INVOICES inv
        ON
            inv.CENTER = il.CENTER
        AND inv.ID = il.ID
        LEFT JOIN
            CREDIT_NOTE_LINES_MT cn
        ON
            cn.ACCOUNT_TRANS_CENTER = find_trans.CENTER
        AND cn.ACCOUNT_TRANS_ID = find_trans.ID
        AND cn.ACCOUNT_TRANS_SUBID = find_trans.SUBID
        AND find_trans.TRANS_TYPE=5
        LEFT JOIN
            credit_notes cre
        ON
            cre.CENTER = cn.CENTER
        AND cre.ID = cn.ID
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
        AND ar.ID = art.ID ) x
LEFT JOIN
    EMPLOYEES emp
ON
    x."Employee_Center" = emp.center
AND x."Employee_ID" = emp.id
LEFT JOIN
    PERSONS staff
ON
    emp.personcenter = staff.center
AND emp.personid = staff.id
LEFT JOIN
    CENTERS ce_debit
ON
    ce_debit.id = DEBIT_ACCOUNTCENTER     
LEFT JOIN
    CENTERS ce_credit
ON
    ce_credit.id = CREDIT_ACCOUNTCENTER          
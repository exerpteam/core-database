-- The extract is extracted from Exerp on 2026-02-08
-- EC-8391
SELECT
    longtodateC(ACT.TRANS_TIME, ACT.center)::DATE AS "Book date",
    ACT.TEXT                                      AS "Text",
    AC1.EXTERNAL_ID                               AS "Debit",
    CASE
        WHEN act.TRANS_TYPE=5
        THEN ACT.AMOUNT
        ELSE ACT.AMOUNT * -1
    END                                              AS "Amount",
    AC2.EXTERNAL_ID                                  AS "Credit",
    AC1.NAME || ' ('||ac1.center||'acc'||ac1.id||')' AS "Debit account",
    AC2.NAME || ' ('||ac2.center||'acc'||ac2.id||')' AS "Credit account",
    CASE
        WHEN act.TRANS_TYPE=5
        THEN ACT1.AMOUNT
        ELSE ACT1.AMOUNT * -1
    END     AS "VAT",
    VT.NAME AS "VAT type",
    CASE act.TRANS_TYPE
        WHEN 1
        THEN 'GL'
        WHEN 2
        THEN 'AR'
        WHEN 3
        THEN 'AccountPayable'
        WHEN 4
        THEN 'InvoiceLine'
        WHEN 5
        THEN 'CreditNoteLine'
        WHEN 6
        THEN 'BillLine'
        ELSE 'Undefined'
    END                                                                    AS "Type",
    TO_CHAR(longtodateC(ACT.entry_time, ACT.center), 'YYYY-MM-DD HH24:MI')  AS "Entry time" ,
    ACT.AGGREGATED_TRANSACTION_CENTER||'agt'||ACT.AGGREGATED_TRANSACTION_ID AS "Aggr. trans. id" ,
    il.center||'inv'||il.id                                                 AS "Invoice" ,
    COALESCE(il.person_center||'p'||il.person_id, cl.person_center||'p'||cl.person_id,
    cl_cr.person_center||'p'||cl_cr.person_id, il_cross.person_center||'p'||il_cross.person_id) AS
    "Member",
    (
        SELECT
            shortname
        FROM
            centers
        WHERE
            id= ACT.CENTER) AS "Center name",
    (
        SELECT
            name
        FROM
            centers
        WHERE
            id= ACT.DEBIT_ACCOUNTCENTER) AS "Debit center",
    (
        SELECT
            name
        FROM
            centers
        WHERE
            id= ACT.CREDIT_ACCOUNTCENTER) AS "Credit center",
    ACT.INFO                              AS "Info",
    CASE ACT.INFO_TYPE
        WHEN 1
        THEN 'Legacy'
        WHEN 2
        THEN 'DataConversion'
        WHEN 3
        THEN 'EFT-File'
        WHEN 4
        THEN 'Debt collection-File'
        WHEN 5
        THEN 'AR'
        WHEN 6
        THEN 'CashRegister'
        WHEN 7
        THEN 'OtherGL'
        WHEN 8
        THEN 'API'
        WHEN 9
        THEN 'CreditCard'
        WHEN 10
        THEN 'VoucherRegistration'
        WHEN 11
        THEN 'AccountReceivableOwner'
        WHEN 12
        THEN 'CashRegisterManual'
        WHEN 13
        THEN 'Inventory'
        WHEN 14
        THEN 'GiftCard'
        WHEN 15
        THEN 'Delivery'
        WHEN 16
        THEN 'OwnerManualPaymentOfRequest'
        WHEN 17
        THEN 'UnplacedPayment'
        WHEN 18
        THEN 'ControlDeviceId'
        WHEN 19
        THEN 'RevokePaymentAgreementReference'
        WHEN 20
        THEN 'CashRegisterBankIdentifier'
        WHEN 21
        THEN 'ArTransImportFile'
        WHEN 22
        THEN 'RevertArTransImportFile'
        WHEN 23
        THEN 'PaymentOfRequestByAPIUser'
        WHEN 24
        THEN 'MOBILE_API'
        WHEN 25
        THEN 'EFT-File-refund'
        WHEN 26
        THEN 'PaymentOfRequestByMAPIUser'
        WHEN 27
        THEN 'AutoRenewal'
        WHEN 28
        THEN 'DebtPaymentByInstallment'
        WHEN 29
        THEN 'StopInstallmentPlan'
        WHEN 30
        THEN 'InstallmentPlan'
        ELSE 'Undefined'
    END                                           AS "Info type",
    act.center||'acc'||act.id||'tr'||act.subid    AS "Account transaction id",
    act1.center||'acc'||act1.id||'tr'||act1.subid AS "VAT transaction id",
    CASE
        WHEN act.TRANS_TYPE=5
        THEN ACT1.DEBIT_ACCOUNTCENTER ||'acc'|| ACT1.DEBIT_ACCOUNTID
        ELSE ACT1.CREDIT_ACCOUNTCENTER ||'acc'|| ACT1.CREDIT_ACCOUNTID
    END AS "VAT transaction account id",
    TO_DATE(substring(COALESCE( art_c.text, inv.text, art_c_cr.text, inv_cross.text),
    '\d{2}.\d{2}.\d{4}'), 'DD.MM.YYYY') AS "Invoice start date",
    TO_DATE(substring(COALESCE( art_c.text, inv.text, art_c_cr.text, inv_cross.text),
    '- (\d{2}.\d{2}.\d{4})'), 'DD.MM.YYYY') AS "Invoice end date",
    coalesce(emp_p.fullname, 'System')                          AS "Employee name"
FROM
    ACCOUNT_TRANS AS ACT
JOIN
    ACCOUNTS AS AC1
ON
    (
        ACT.DEBIT_ACCOUNTCENTER = AC1.CENTER
    AND ACT.DEBIT_ACCOUNTID = AC1.ID)
JOIN
    ACCOUNTS AS AC2
ON
    (
        ACT.CREDIT_ACCOUNTCENTER = AC2.CENTER
    AND ACT.CREDIT_ACCOUNTID = AC2.ID)
LEFT JOIN
    ACCOUNT_TRANS AS ACT1
ON
    (
        ACT.CENTER = ACT1.MAIN_TRANSCENTER
    AND ACT.ID = ACT1.MAIN_TRANSID
    AND ACT.SUBID = ACT1.MAIN_TRANSSUBID)
LEFT JOIN
    VAT_TYPES AS VT
ON
    (
        ACT1.VAT_TYPE_CENTER = VT.CENTER
    AND ACT1.VAT_TYPE_ID = VT.ID)
LEFT JOIN
    INVOICE_LINES_MT AS IL
ON
    (
        IL.ACCOUNT_TRANS_CENTER = ACT.CENTER
    AND IL.ACCOUNT_TRANS_ID = ACT.ID
    AND IL.ACCOUNT_TRANS_SUBID = ACT.SUBID)
LEFT JOIN
    invoices inv
ON
    il.center=inv.center
AND il.id=inv.id
LEFT JOIN
    credit_note_lines_mt AS cL
ON
    (
        cL.ACCOUNT_TRANS_CENTER = ACT.CENTER
    AND cL.ACCOUNT_TRANS_ID = ACT.ID
    AND cL.ACCOUNT_TRANS_SUBID = ACT.SUBID )
LEFT JOIN
    credit_notes cn
ON
    (
        cn.center=cl.center
    AND cn.id=cl.id )
LEFT JOIN
    AR_TRANS AS ART_C
ON
    (
        ART_C.REF_CENTER = cL.CENTER
    AND ART_C.REF_ID = cL.ID
    AND ART_C.REF_TYPE = 'CREDIT_NOTE' )
LEFT JOIN
    account_trans act_cross_cred
ON
    act.center=act_cross_cred.debit_transaction_center
AND act.id=act_cross_cred.debit_transaction_id
AND act.subid=act_cross_cred.debit_transaction_subid
AND ac1.name LIKE 'Debt to %'
LEFT JOIN
    credit_note_lines_mt AS cL_cr
ON
    COALESCE(act_cross_cred.main_transcenter, act_cross_cred.center)=cL_cr.ACCOUNT_TRANS_CENTER
AND COALESCE(act_cross_cred.main_transid, act_cross_cred.id )=cL_cr.ACCOUNT_TRANS_ID
AND COALESCE(act_cross_cred.main_transsubid, act_cross_cred.subid)=cL_cr.ACCOUNT_TRANS_SUBID
LEFT JOIN
    credit_notes cn_cr
ON
    (
        cn_cr.center=cL_cr.center
    AND cn_cr.id=cL_cr.id )
LEFT JOIN
    AR_TRANS AS ART_C_CR
ON
    (
        ART_C_CR.REF_CENTER = cL_cr.CENTER
    AND ART_C_CR.REF_ID = cL_cr.ID
    AND ART_C_CR.REF_TYPE = 'CREDIT_NOTE' )
LEFT JOIN
    ACCOUNT_TRANS AS ACT_inv_cross
ON
    (
        ACT_inv_cross.CENTER = ACT.debit_transaction_center
    AND ACT_inv_cross.ID = ACT.debit_transaction_id
    AND ACT_inv_cross.SUBID = ACT.debit_transaction_subid
    AND ac2.name LIKE 'Debt to %' )
LEFT JOIN
    INVOICE_LINES_MT AS IL_cross
ON
    (
        COALESCE(ACT_inv_cross.main_transcenter, ACT_inv_cross.CENTER) =
        IL_cross.ACCOUNT_TRANS_CENTER
    AND COALESCE(ACT_inv_cross.main_transid, ACT_inv_cross.ID) = IL_cross.ACCOUNT_TRANS_id
    AND COALESCE(ACT_inv_cross.main_transsubid, ACT_inv_cross.SUBID) = IL_cross.ACCOUNT_TRANS_subid
    )
LEFT JOIN
    invoices inv_cross
ON
    IL_cross.center=inv_cross.center
AND IL_cross.id=inv_cross.id
LEFT JOIN
    employees emp
ON
    COALESCE(cn.employee_center, inv.employee_center,cn_cr.employee_center,
    inv_cross.employee_center) =emp.center
AND COALESCE(cn.employee_id, inv.employee_id, cn_cr.employee_id, inv_cross.employee_id)=emp.id
LEFT JOIN
    persons emp_p
ON
    emp.personcenter=emp_p.center
AND emp.personid=emp_p.id
WHERE
    (
        ACT.CENTER IN (:centers)
    AND ACT.TRANS_TIME >= getstartofday((:start_date)::date::varchar, 100)
    AND ACT.TRANS_TIME <= getendofday((:end_date)::date::varchar, 100)
    AND ACT.MAIN_TRANSCENTER IS NULL)
AND (
        act.TRANS_TYPE=5
    OR  ACT.INFO='WriteOff')
ORDER BY
    ACT.TRANS_TIME,
    ACT.SUBID
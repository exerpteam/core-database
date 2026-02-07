WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                   AS FromDate,
            ($$ToDate$$ + 86400 * 1000)-1  AS Todate
        FROM
            dual
    )
SELECT
    CASE
        WHEN invl.person_center IS NOT NULL
        THEN invl.person_center || 'p' || invl.person_id
        WHEN il2.person_center IS NOT NULL
        THEN il2.person_center || 'p' || il2.person_id
        WHEN il2main.person_center IS NOT NULL
        THEN il2main.person_center || 'p' || il2main.person_id
        WHEN ar.customercenter IS NOT NULL
        THEN ar.customercenter || 'p' || ar.customerid
        WHEN cn.person_center IS NOT NULL
        THEN cn.person_center || 'p' || cn.person_id
    END AS Personid,
    prs.ref AS InvoiceNumber,
    c.external_id AS center,
    longtodatec(ACT1.TRANS_TIME, act1.center) AS bookdate,
    act1.aggregated_transaction_center || 'agt' || act1.aggregated_transaction_id ||':' || ac2.name AS text,
    AC1.EXTERNAL_ID    AS debit,
    AC2.EXTERNAL_ID    AS credit,
    ACT1.AMOUNT        AS amount,
    ACT2.AMOUNT        AS vat,
    VT.EXTERNAL_ID     AS taxcode,
    act1.aggregated_transaction_center || 'agt' || act1.aggregated_transaction_id AS AggrTransId,
    ACT1.TEXT          AS Trans_Text,
    DECODE(ACT1.INFO_TYPE,1,'Legacy',2,'Data Migration',3,'Clearing House File',4,'Debt Collection File',5,'Account Receivable',6,'Cash Register',7,'Other transactions', 8,'External API',9,'Credit Card',10,'Expense Voucher',11,'Manual transaction',12,'Manual cash register',13,'Inventory',14,'Gift card', 15,'Delivery', 16,'Manual payment',17,'Unplaced payment',18,'Control device id',19,'Revoke payment agreement reference',22,'Import and revert ar transaction', 23,'Payment of request by API user',24,'External Mobile API',26,'Payment of request by MAPI user') 
	                   AS InfoType,
    ACT1.INFO          AS INFO 
FROM
    account_trans ACT1
CROSS JOIN
    params
JOIN
    centers c
ON
    c.id = act1.center
JOIN
    ACCOUNTS AC1
ON
    ACT1.DEBIT_ACCOUNTCENTER = AC1.CENTER
    AND ACT1.DEBIT_ACCOUNTID = AC1.ID
JOIN
    ACCOUNTS AC2
ON
    ACT1.CREDIT_ACCOUNTCENTER = AC2.CENTER
    AND ACT1.CREDIT_ACCOUNTID = AC2.ID
LEFT JOIN
    ACCOUNT_TRANS ACT2
ON
    ACT2.MAIN_TRANSCENTER = ACT1.CENTER
    AND ACT2.MAIN_TRANSID = ACT1.ID
    AND ACT2.MAIN_TRANSSUBID = ACT1.SUBID
LEFT JOIN
    ACCOUNTS AC3
ON
    ACT2.DEBIT_ACCOUNTCENTER = AC3.CENTER
    AND ACT2.DEBIT_ACCOUNTID = AC3.ID
LEFT JOIN
    ACCOUNTS AC4
ON
    ACT2.CREDIT_ACCOUNTCENTER = AC4.CENTER
    AND ACT2.CREDIT_ACCOUNTID = AC4.ID
LEFT JOIN
    VAT_TYPES VT
ON
    ACT2.VAT_TYPE_CENTER = VT.CENTER
    AND ACT2.VAT_TYPE_ID = VT.ID
LEFT JOIN
    invoice_lines_mt invl
ON
    invl.account_trans_center = act1.center
    AND invl.account_trans_id = act1.id
    AND invl.account_trans_subid = act1.subid
    AND act1.TRANS_TYPE=4
LEFT JOIN
    va.ar_trans art3
ON
    art3.ref_center = invl.center
    AND art3.ref_id = invl.id
    AND art3.ref_type = 'INVOICE'
LEFT JOIN
    ACCOUNT_TRANS debit
ON
    act1.DEBIT_TRANSACTION_CENTER = debit.CENTER
    AND act1.DEBIT_TRANSACTION_ID = debit.ID
    AND act1.DEBIT_TRANSACTION_SUBID = debit.SUBID
LEFT JOIN
    INVOICE_LINES_MT il2
ON
    il2.ACCOUNT_TRANS_CENTER = debit.CENTER
    AND il2.ACCOUNT_TRANS_ID = debit.ID
    AND il2.ACCOUNT_TRANS_SUBID = debit.SUBID
    AND debit.TRANS_TYPE=4
LEFT JOIN
    INVOICE_LINES_MT il2main
ON
    il2main.ACCOUNT_TRANS_CENTER = debit.MAIN_TRANSCENTER
    AND il2main.ACCOUNT_TRANS_ID = debit.MAIN_TRANSID
    AND il2main.ACCOUNT_TRANS_SUBID = debit.MAIN_TRANSSUBID
    AND debit.TRANS_TYPE=4
LEFT JOIN
    AR_TRANS art
ON
    art.REF_CENTER = act1.CENTER
    AND art.REF_ID = act1.ID
    AND art.REF_SUBID = act1.SUBID
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
    AND act1.TRANS_TYPE=2
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
LEFT JOIN
    CREDIT_NOTE_LINES_MT cn
ON
    cn.ACCOUNT_TRANS_CENTER = act1.CENTER
    AND cn.ACCOUNT_TRANS_ID = act1.ID
    AND cn.ACCOUNT_TRANS_SUBID = act1.SUBID
    AND act1.TRANS_TYPE=5
LEFT JOIN
    ar_trans art2
ON
    art2.ref_type = 'INVOICE'
    AND((
            art2.ref_center = invl.center
            AND art2.ref_id = invl.id)
        OR (
            art2.ref_center = il2.center
            AND art2.ref_id = il2.id)
        OR (
            art2.ref_center = il2main.center
            AND art2.ref_id = il2main.id))
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    (
        prs.center = art2.payreq_spec_center
        AND prs.id = art2.payreq_spec_id
        AND prs.subid = art2.payreq_spec_subid)
    OR (
        prs.center = art.payreq_spec_center
        AND prs.id = art.payreq_spec_id
        AND prs.subid = art.payreq_spec_subid)
WHERE
    ACT1.MAIN_TRANSCENTER IS NULL
    AND ACT1.MAIN_TRANSID IS NULL
    AND ACT1.MAIN_TRANSSUBID IS NULL
    AND ACT1.CENTER IN ($$Scope$$)
    AND ACT1.TRANSFERRED = 1
    AND ACT1.TRANS_TIME >= params.FromDate
    AND ACT1.TRANS_TIME <= params.ToDate
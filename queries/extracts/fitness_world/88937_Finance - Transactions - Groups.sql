-- The extract is extracted from Exerp on 2026-02-08
--  


WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$ToDate$$                      AS fromDate,
            $$FromDate$$  AS toDate
        FROM
            dual
    )

SELECT

TO_CHAR(longtodateC(atr.ENTRY_TIME, atr.center),'DD-MM-YYYY') AS "Book date",
atr.TEXT as "Text",
debit.external_id as "Debit",
round(atr.amount,2) as "Amount",
credit.external_id as "Credit",
debit.name||' ('||debit.center||'acc'||debit.id||')' as "Debit account",
credit.name||' ('||credit.center||'acc'||credit.id||')' as "Credit account",

vat.amount as "VAT",
vt.name as "VAT type",

CASE atr.TRANS_TYPE WHEN 1 THEN 'General Ledger' WHEN 2 THEN 'Account Receivable' WHEN 3 THEN 'Account Payable' WHEN 4 THEN 'Invoice Line' WHEN 5 THEN 'Credit Note Line' WHEN 6 THEN 'Bill Line' ELSE 'Undefined' END
as "Type",

TO_CHAR(longtodateC(atr.ENTRY_TIME, atr.center),'DD-MM-YYYY HH24:MI') as "Entry time",
atr.aggregated_transaction_id as "Aggr. trans. id", --blank

case when il.center is not null then il.center||'inv'||il.id else '' end as "Invoice",
case when i.PAYER_CENTER is not null then i.PAYER_CENTER||'p'||i.PAYER_ID else '' end as "Member",

c.name as "Center name",
debit_center.name as "Debit center",
credit_center.name as "Credit center",


atr.info as "Info",

CASE atr.INFO_TYPE WHEN 1 THEN 'Legacy' WHEN 2 THEN 'DataConversion' WHEN 3 THEN 'EFT-File' WHEN 4 THEN 'Debt collection-File' WHEN 5 THEN 'AR' WHEN 6 THEN 'CashRegister' WHEN 7 THEN 'OtherGL' WHEN 8 THEN 'API' WHEN 9 THEN 'CreditCard' WHEN 10 THEN 'VoucherRegistration' WHEN 11 THEN 'AccountReceivableOwner' WHEN 12 THEN 'CashRegisterManual' WHEN 13 THEN 'Inventory' WHEN 14 THEN 'GiftCard' WHEN 15 THEN 'Delivery' WHEN 16 THEN 'OwnerManualPaymentOfRequest' WHEN 17 THEN 'UnplacedPayment' ELSE 'Undefined' END
as "Info type",

atr.center||'acc'||atr.id||'tr'||atr.subid as "Account transaction id",

CASE WHEN vat.center is not null
     THEN vat.center||'acc'||vat.id||'tr'||vat.subid
     ELSE ''
     END as "VAT transaction id",
     
 CASE WHEN vat.credit_accountcenter is not null
     THEN vat.credit_accountcenter||'acc'||vat.credit_accountid
     ELSE ''
     END as "VAT transaction account id"

FROM ACCOUNT_TRANS atr 

LEFT JOIN INVOICE_LINES_MT il ON atr.center = il.ACCOUNT_TRANS_CENTER
AND atr.id = il.ACCOUNT_TRANS_ID
AND atr.SUBID = il.ACCOUNT_TRANS_SUBID 

LEFT JOIN INVOICES i ON i.CENTER = il.CENTER
AND i.ID = il.ID

LEFT JOIN
    ACCOUNTS debit
ON
    debit.center = atr.DEBIT_ACCOUNTCENTER
AND debit.id = atr.DEBIT_ACCOUNTID
LEFT JOIN
    ACCOUNTS credit
ON
    credit.center = atr.CREDIT_ACCOUNTCENTER
AND credit.id = atr.CREDIT_ACCOUNTID 
LEFT JOIN
    INVOICELINES_VAT_AT_LINK ivat
ON
    ivat.INVOICELINE_CENTER=il.CENTER
AND ivat.INVOICELINE_ID=il.ID
AND ivat.INVOICELINE_SUBID=il.SUBID
left JOIN
    ACCOUNT_TRANS vat
ON
    vat.center = ivat.ACCOUNT_TRANS_CENTER
AND vat.id = ivat.ACCOUNT_TRANS_ID
AND vat.SUBID = ivat.ACCOUNT_TRANS_SUBID
LEFT JOIN
    ACCOUNTS debitv
ON
    debitv.center = vat.DEBIT_ACCOUNTCENTER
AND debitv.id = vat.DEBIT_ACCOUNTID
LEFT JOIN
    ACCOUNTS creditv
ON
    creditv.center = vat.CREDIT_ACCOUNTCENTER
AND creditv.id = vat.CREDIT_ACCOUNTID
LEFT JOIN
    AR_TRANS art
ON
    art.REF_CENTER = i.CENTER
AND art.REF_ID = i.ID
AND art.REF_TYPE = 'INVOICE'

left join vat_types vt
on vat.vat_type_center = vt.center and vat.vat_type_id = vt.id

left join centers c on atr.CENTER = c.id
left join centers debit_center on debit.center = debit_center.id
left join centers credit_center on credit.center = credit_center.id

CROSS JOIN params

WHERE 
credit.globalid not in ('VAT_SALES_50_50', 'VAT_SALES_25_00')
and

atr.CENTER in (:centers)

AND atr.ENTRY_TIME BETWEEN params.fromDate AND params.toDate

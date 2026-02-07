WITH
    PARAMS AS
    (
        SELECT
                :fromDate AS fromDate,
                :fromDate + 86400000 AS toDate 
        FROM dual
    )
SELECT
        cp.EXTERNAL_ID AS "External ID",
        (CASE 
                WHEN p.CENTER IS NULL THEN NULL
                ELSE p.CENTER || 'p' || p.ID
        END) AS "Person ID",
        p.CENTER AS "Home center ID",
        t1.GlobalSubscriptionId AS "Subscription ID",
        t1.Text AS "Product",
        t1.TransactionType AS "Transaction type",
        t1.EntryTime AS "Transaction date",
        (CASE
                WHEN t1.Text LIKE 'Joining%' THEN 'Joining fee'
                WHEN t1.artran_text LIKE 'New subscription sale:%' THEN 'Membership change'
                WHEN t1.INFO_TYPE=8 AND t1.artran_text='Subscription sale API' AND t1.Employee='100emp17401' THEN 'Membership sale'   
                WHEN t1.PTYPE=2 AND t1.PRODUCT_GROUP_ID=9 THEN 'API product usage'
                ELSE NULL
        END) AS "Transaction context",
        (CASE t1.TRANS_TYPE
                WHEN 4 THEN -t1.AMOUNT
                ELSE t1.AMOUNT
        END) AS "Amount",
        (CASE t1.TRANS_TYPE
                WHEN 4 THEN -t1.VAT
                ELSE t1.VAT 
        END) AS "VAT",
        cc.CODE AS "Campaign Code",
        (CASE t1.TRANS_TYPE
                WHEN 4 THEN -(t1.AMOUNT + t1.VAT)
                ELSE t1.AMOUNT + t1.VAT
        END) AS "Total amount taken",
        t1.INFO AS "Info",
		t1.Debit, 
		t1.Credit,
		t1.Debit_account,
		t1.Credit_account
		
        /*DECODE (t1.INFO_TYPE, 1,'Legacy', 2,'DataConversion', 3,'EFT-File', 4,'Debt collection-File', 5,'ARReason', 
                               6,'CashRegister', 7,'OtherGL', 8,'API', 9,'CreditCard', 10,'VoucherRegistration', 
                               11,'AccountReceivableOwner', 12,'CashRegisterManual', 13,'Inventory', 14,'GiftCard', 
                               15,'Delivery', 16,'OwnerManualPaymentOfRequest', 17,'UnplacedPayment', 'UNKNOWN'
        ) AS "InfoType"*/
FROM
(
        SELECT
                (CASE
                         WHEN act.TRANS_TYPE=2 THEN ar.CUSTOMERCENTER
                         WHEN act.TRANS_TYPE=4 AND il.PERSON_CENTER IS NOT NULL THEN il.PERSON_CENTER
                         WHEN act.TRANS_TYPE=5 THEN cn.PERSON_CENTER  
                         WHEN act.TRANS_TYPE=4 AND act.DEBIT_TRANSACTION_CENTER IS NOT NULL AND debit.MAIN_TRANSCENTER IS NULL THEN il2.PERSON_CENTER
                         WHEN act.TRANS_TYPE=4 AND act.DEBIT_TRANSACTION_CENTER IS NOT NULL AND debit.MAIN_TRANSCENTER IS NOT NULL THEN il2main.PERSON_CENTER
                         ELSE NULL
                END) PersonCenter,
                (CASE
                         WHEN act.TRANS_TYPE=2 THEN ar.CUSTOMERID
                         WHEN act.TRANS_TYPE=4 AND il.PERSON_ID IS NOT NULL THEN il.PERSON_ID
                         WHEN act.TRANS_TYPE=5 THEN cn.PERSON_ID  
                         WHEN act.TRANS_TYPE=4 AND act.DEBIT_TRANSACTION_CENTER IS NOT NULL AND debit.MAIN_TRANSCENTER IS NULL THEN il2.PERSON_ID
                         WHEN act.TRANS_TYPE=4 AND act.DEBIT_TRANSACTION_CENTER IS NOT NULL AND debit.MAIN_TRANSCENTER IS NOT NULL THEN il2main.PERSON_ID
                         ELSE NULL
                END) PersonId,
                --TO_CHAR(longtodateC(act.TRANS_TIME,act.CENTER), 'YYYY-MM-DD HH24:MI') AS BookDate,
                (CASE
                        WHEN act.TRANS_TYPE=1 THEN 'General ledger'
                        WHEN act.TRANS_TYPE=2 THEN 'Account receivables'
                        WHEN act.TRANS_TYPE=3 THEN 'Account payables'
                        WHEN act.TRANS_TYPE=4 THEN 'Invoice line'
                        WHEN act.TRANS_TYPE=5 THEN 'Credit note line'
                        WHEN act.TRANS_TYPE=6 THEN 'Bill line'
                        ELSE 'Unknown'
                END) AS TransactionType,
                TO_CHAR(longtodateC(act.ENTRY_TIME,act.CENTER), 'YYYY-MM-DD HH24:MI') AS EntryTime,
                NVL(act.AMOUNT,0) AS AMOUNT,
                NVL(vatTran.AMOUNT,0) AS VAT,
                act.TEXT,
                act.TRANS_TYPE, 
                (CASE
                        WHEN act.TRANS_TYPE=4 THEN s.center||'ss'||s.id
                        WHEN act.TRANS_TYPE=5 THEN s2.center||'ss'||s2.id
                        ELSE NULL
                END) AS GlobalSubscriptionId,
                act.INFO,
                act.INFO_TYPE,
                il.CENTER AS ilCenter,
                il.ID AS ilId,
                il.SUBID AS ilSubid, 
                artil.TEXT AS artran_text, 
                artil.EMPLOYEECENTER || 'emp' || artil.EMPLOYEEID AS Employee,
                prService.PTYPE,
                prlink.PRODUCT_GROUP_ID,
				debitAccount.external_id  AS Debit,
				creditAccount.external_id AS Credit,
				debitAccount.name AS Debit_account,
				creditAccount.name AS Credit_account
        FROM params
        CROSS JOIN ACCOUNT_TRANS act 
        JOIN CENTERS c
                ON c.ID = act.CENTER
        LEFT JOIN ACCOUNTS creditAccount
                ON creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER AND creditAccount.ID = act.CREDIT_ACCOUNTID        
        LEFT JOIN ACCOUNTS debitAccount
                ON debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER AND debitAccount.ID = act.DEBIT_ACCOUNTID    
        LEFT JOIN ACCOUNT_TRANS vatTran
                ON vatTran.MAIN_TRANSCENTER = act.CENTER AND vatTran.MAIN_TRANSID = act.ID AND vatTran.MAIN_TRANSSUBID = act.SUBID
        LEFT JOIN VAT_TYPES vatType
                ON vatType.CENTER = vatTran.VAT_TYPE_CENTER AND vatType.ID = vatTran.VAT_TYPE_ID
        LEFT JOIN INVOICE_LINES_MT il
                ON il.ACCOUNT_TRANS_CENTER = act.CENTER AND il.ACCOUNT_TRANS_ID = act.ID AND il.ACCOUNT_TRANS_SUBID = act.SUBID AND act.TRANS_TYPE=4
		LEFT JOIN PUREGYM.PRODUCTS pr 
				ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID
        LEFT JOIN AR_TRANS artil
                ON artil.REF_CENTER = il.CENTER AND artil.REF_ID = il.ID AND artil.REF_TYPE = 'INVOICE'
        LEFT JOIN PRODUCTS prService
                ON prService.CENTER = il.PRODUCTCENTER AND prService.ID = il.PRODUCTID AND prService.PTYPE = 2
        LEFT JOIN PUREGYM.PRODUCT_AND_PRODUCT_GROUP_LINK prlink
                ON prlink.PRODUCT_CENTER = prService.CENTER AND prlink.PRODUCT_ID = prService.ID AND prlink.PRODUCT_GROUP_ID = 9 -- Add-ons
        LEFT JOIN SPP_INVOICELINES_LINK spplink
                ON spplink.INVOICELINE_CENTER = il.CENTER AND spplink.INVOICELINE_ID = il.ID AND spplink.INVOICELINE_SUBID = il.SUBID
        LEFT JOIN SUBSCRIPTIONPERIODPARTS spp
                ON spp.CENTER = spplink.PERIOD_CENTER AND spp.ID = spplink.PERIOD_ID AND spp.SUBID = spplink.PERIOD_SUBID
        LEFT JOIN SUBSCRIPTIONS s
                ON s.CENTER = spp.CENTER AND s.ID = spp.ID
        LEFT JOIN CREDIT_NOTE_LINES_MT cn
                ON cn.ACCOUNT_TRANS_CENTER = act.CENTER AND cn.ACCOUNT_TRANS_ID = act.ID AND cn.ACCOUNT_TRANS_SUBID = act.SUBID AND act.TRANS_TYPE=5
		LEFT JOIN PUREGYM.PRODUCTS pr2 
                ON pr2.CENTER = cn.PRODUCTCENTER AND pr2.ID = cn.PRODUCTID
        LEFT JOIN SPP_INVOICELINES_LINK spplink2
                ON spplink2.INVOICELINE_CENTER = cn.CENTER AND spplink2.INVOICELINE_ID = cn.ID AND spplink2.INVOICELINE_SUBID = cn.SUBID
        LEFT JOIN SUBSCRIPTIONPERIODPARTS spp2
                ON spp2.CENTER = spplink2.PERIOD_CENTER AND spp2.ID = spplink2.PERIOD_ID AND spp2.SUBID = spplink2.PERIOD_SUBID
        LEFT JOIN SUBSCRIPTIONS s2
                ON s2.CENTER = spp2.CENTER AND s2.ID = spp2.ID
        LEFT JOIN PUREGYM.AR_TRANS art
                ON art.REF_CENTER = act.CENTER AND art.REF_ID = act.ID AND art.REF_SUBID = act.SUBID AND art.REF_TYPE = 'ACCOUNT_TRANS' AND act.TRANS_TYPE=2
        LEFT JOIN PUREGYM.ACCOUNT_RECEIVABLES ar
                ON ar.CENTER = art.CENTER AND ar.ID = art.ID
		LEFT JOIN PUREGYM.ACCOUNT_TRANS debit 
                ON act.DEBIT_TRANSACTION_CENTER = debit.CENTER AND act.DEBIT_TRANSACTION_ID = debit.ID AND act.DEBIT_TRANSACTION_SUBID = debit.SUBID
        LEFT JOIN INVOICE_LINES_MT il2
                ON il2.ACCOUNT_TRANS_CENTER = debit.CENTER AND il2.ACCOUNT_TRANS_ID = debit.ID AND il2.ACCOUNT_TRANS_SUBID = debit.SUBID AND debit.TRANS_TYPE=4
        LEFT JOIN INVOICE_LINES_MT il2main
                ON il2main.ACCOUNT_TRANS_CENTER = debit.MAIN_TRANSCENTER AND il2main.ACCOUNT_TRANS_ID = debit.MAIN_TRANSID AND il2main.ACCOUNT_TRANS_SUBID = debit.MAIN_TRANSSUBID AND debit.TRANS_TYPE=4
        WHERE 
                act.ENTRY_TIME >= params.fromDate
                AND act.ENTRY_TIME < params.toDate
                AND act.CENTER IN (:Scope)
                AND act.MAIN_TRANSCENTER IS NULL
        ORDER BY
                act.TRANS_TIME
) t1
LEFT JOIN PERSONS p ON t1.PersonCenter = p.CENTER AND t1.PersonId = p.ID
LEFT JOIN PERSONS cp ON p.CURRENT_PERSON_CENTER = cp.CENTER AND p.CURRENT_PERSON_ID = cp.ID
LEFT JOIN PUREGYM.PRIVILEGE_USAGES pu ON pu.TARGET_SERVICE = 'InvoiceLine' AND pu.TARGET_CENTER = t1.ilCenter AND pu.TARGET_ID = t1.ilId AND pu.TARGET_SUBID = t1.ilSubid
LEFT JOIN PUREGYM.CAMPAIGN_CODES cc ON pu.CAMPAIGN_CODE_ID = cc.ID
        

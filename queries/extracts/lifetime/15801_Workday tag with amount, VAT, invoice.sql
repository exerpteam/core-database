-- The extract is extracted from Exerp on 2026-02-08
-- Migration to ExerpPOS
WITH
        params AS MATERIALIZED
        (
         SELECT
                    dateToLongC (TO_CHAR (to_date ('2024-10-25', 'yyyy-mm-dd'), 'yyyy-mm-dd'), c.id) AS fromDate,
                    dateToLongC (TO_CHAR (to_date ('2025-02-26', 'yyyy-mm-dd'), 'yyyy-mm-dd'), c.id) AS toDate,
                    c.id
               FROM
                    centers c
        )
 SELECT
            (
                CASE
                    WHEN act.TRANS_TYPE = 1
                    THEN 'General ledger'
                    WHEN act.TRANS_TYPE = 2
                    THEN 'Account receivables'
                    WHEN act.TRANS_TYPE = 3
                    THEN 'Account payables'
                    WHEN act.TRANS_TYPE = 4
                    THEN 'Invoice line'
                    WHEN act.TRANS_TYPE = 5
                    THEN 'Credit note line'
                    WHEN act.TRANS_TYPE = 6
                    THEN 'Bill line'
                    ELSE 'Unknown'
                END)                                                                 AS TransactionType,
            act.center as "Transaction Center",
            TO_CHAR (longtodateC (act.ENTRY_TIME, act.CENTER), 'YYYY-MM-DD HH24:MI') AS EntryTime,
            CASE when act.trans_type = 5 THEN
            COALESCE ( - act.AMOUNT, 0)
            ELSE COALESCE(act.AMOUNT, 0)END                                          AS AMOUNT,
            pr.price as normalprice,
            il.quantity,
            CASE WHEN act.trans_type = 4 and act.amount < pr.price * il.quantity
            THEN pr.price * il.quantity - act.amount 
            ELSE 0 END AS discount,
            COALESCE (vatTran.AMOUNT, 0)                                             AS VAT,
            vatType.rate * 100 || '%' as "VAT Percentage",
            act.TEXT as "transaction text",
            pr.globalid as product,
            mpr.id as master_product_id,
            
            -- act.TRANS_TYPE,
            /*        (CASE
            WHEN act.TRANS_TYPE=4 THEN pr.GLOBALID
            WHEN act.TRANS_TYPE=5 THEN pr2.GLOBALID
            ELSE NULL
            END) AS GlobalSubscriptionId,*/
            il.center || 'inv'||il.id||'inv'||il.subid as invoice_line,
            cnl.center || 'crd' || cnl.id || 'crd'|| cnl.subid as credit_note_line,
            pg.external_id AS "WorkdayCostCenter | WorkdayOffering",
            CASE
            WHEN act.TRANS_TYPE = 4
                    THEN creditAccount.name
                    WHEN act.TRANS_TYPE = 5
                    THEN debitAccount.name
                    END AS "Income/Refund Account",
            --creditAccount.name as "Credit Account",
            --debitAccount.name as "Debit Account",
            CASE
            WHEN act.TRANS_TYPE = 4
            THEN creditAccount.external_id 
            WHEN act.TRANS_TYPE = 5
            THEN debitAccount.external_id
            END AS "WorkdayAccount | RevenueCategory"            
       FROM
            lifetime.account_trans act
       LEFT JOIN
            aggregated_transactions agt ON agt.center = act.aggregated_transaction_center AND agt.id = act.aggregated_transaction_id
       JOIN
            params par ON act.center = par.id
       JOIN
            lifetime.accounts creditAccount ON creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER AND creditAccount.ID = act.CREDIT_ACCOUNTID
       JOIN
            lifetime.accounts debitAccount ON debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER AND debitAccount.ID = act.DEBIT_ACCOUNTID
  LEFT JOIN
            lifetime.account_trans vatTran ON vatTran.MAIN_TRANSCENTER = act.CENTER AND vatTran.MAIN_TRANSID = act.ID AND vatTran.MAIN_TRANSSUBID =
            act.SUBID
  LEFT JOIN
            lifetime.vat_types vatType ON vatType.CENTER = vatTran.VAT_TYPE_CENTER AND vatType.ID = vatTran.VAT_TYPE_ID
   LEFT JOIN 
            lifetime.credit_note_lines_mt cnl ON cnl.account_trans_center = act.center and cnl.account_trans_id = act.id and cnl.account_trans_subid = act.subid 
  
  LEFT JOIN
            lifetime.invoice_lines_mt il ON (il.ACCOUNT_TRANS_CENTER = act.CENTER AND il.ACCOUNT_TRANS_ID = act.ID AND il.ACCOUNT_TRANS_SUBID =
            act.SUBID ) OR (cnl.invoiceline_center = il.center AND cnl.invoiceline_id = il.id and cnl.invoiceline_subid = il.subid)
  LEFT JOIN
            lifetime.products pr ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID
  JOIN      
            lifetime.masterproductregister mpr ON pr.globalid = mpr.globalid
  LEFT JOIN
            lifetime.product_group pg ON pr.primary_product_group_id = pg.id
  LEFT JOIN
            lifetime.product_group parent ON pg.parent_product_group_id = parent.id
 
            
      WHERE
            il.center IN (:scope) and
            ( debitAccount.external_id IN ('430005 | RC50064',
                                          '430005 | RC50069',
                                          '430005 | RC50081',
                                          '430005 | RC50009',
                                          '430005 | RC50090',
                                          '430005 | RC50175',
                                          '214010 | RC50064',
                                          '214010 | RC50069',
                                          '411005 | RC50016',
                                          '411005 | RC50027',
                                          '460005 | RC50172',
                                          '460005 | RC50173'
                                           ) 
              OR creditAccount.external_id IN ('430005 | RC50064',
                                          '430005 | RC50069',
                                          '430005 | RC50081',
                                          '430005 | RC50009',
                                          '430005 | RC50090',
                                          '430005 | RC50175',
                                          '214010 | RC50064',
                                          '214010 | RC50069',
                                          '411005 | RC50016',
                                          '411005 | RC50027',
                                          '460005 | RC50172',
                                          '460005 | RC50173'
                                           ) )
                                           
                                           ;
                                           
                                           
                                           
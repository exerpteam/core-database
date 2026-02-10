-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/DATA-127
WITH
    PARAMS AS MATERIALIZED
    (   SELECT
            id ,
            CAST(datetolongc(TO_CHAR(CAST(:from_date AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS
            BIGINT) AS fromts,
            CAST(datetolongc(TO_CHAR(CAST(:to_date AS DATE)+interval '1' DAY, 'YYYY-MM-DD HH24:MI'
            ), id) AS BIGINT) AS tots
        FROM
            centers
        WHERE
            id IN (:scope)
    )
SELECT
    act.center||'acc'||act.id||'tr'||act.subid AS Account_Trans_Id,
    COALESCE(cnl.center||'cn'||cnl.id||'ln'||cnl.subid, il.center||'inv'||il.id||'ln'||il.subid) AS invoice_or_credit_id, 
    crt.customercenter||'p'||crt.customerid AS member_id,
    COALESCE(cn.text, il.text, crt.coment, act.text)        AS Description,
    longtodatec(act.trans_time, act.center)    AS DATETIME,
    COALESCE(cnl.total_amount, il.total_amount, act.amount)       AS amount,
    pr.name                 AS product_name,
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
    END                       AS TRANS_TYPE, 
    COALESCE(sac.name,sac_cl.name)                      AS "Ledger Group",
    COALESCE(sac.external_id,sac_cl.external_id)        AS "Ledger Group Code",      
    creditAccount.name        AS Credit_Account, 
    creditAccount.EXTERNAL_ID AS Credit_Account_ExternalID, 
    debitAccount.name         AS Debit_Account, 
    debitAccount.external_id  AS Debit_Account_ExternalID 
FROM 
    ACCOUNT_TRANS act
JOIN
    params
ON
    params.id = act.center
AND act.TRANS_TIME >= params.fromts
AND act.TRANS_TIME < params.toTs
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
JOIN
    cashregistertransactions crt
ON
    act.TRANS_TYPE = 1 -- GL
AND act.center = crt.gltranscenter
AND act.id = crt.gltransid
AND act.subid = crt.gltranssubid
LEFT JOIN
    invoices i
ON
    crt.paysessionid = i.paysessionid
AND
    (
        (
            crt.customercenter = i.payer_center
        AND crt.customerid = i.payer_id)
    OR  crt.customercenter IS NULL)
LEFT JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id
LEFT JOIN
    products pr
ON
    pr.CENTER = il.PRODUCTCENTER
AND pr.ID = il.PRODUCTID
LEFT JOIN
   product_account_configurations prac
ON
   prac.id = pr.product_account_config_id
LEFT JOIN
   accounts sac
ON
    sac.globalid = prac.sales_account_globalid
    AND sac.center = pr.center   
    -- credit notes
LEFT JOIN
    credit_notes cn
ON
    crt.paysessionid = cn.paysessionid
AND
    (
        (
            crt.customercenter = cn.payer_center
        AND crt.customerid = cn.payer_id)
    OR  crt.customercenter IS NULL)
LEFT JOIN
    credit_note_lines_mt cnl
ON
    cn.center = cnl.center
AND cn.id = cnl.id    
LEFT JOIN
   products prod_cl
ON
   prod_cl.center = cnl.productcenter
   AND prod_cl.id = cnl.productid

LEFT JOIN
   product_account_configurations prac_cl
ON
   prac_cl.id = prod_cl.product_account_config_id
LEFT JOIN
   accounts sac_cl
ON
   sac_cl.globalid = prac_cl.sales_account_globalid
   AND sac_cl.center = prod_cl.center  
WHERE
    act.TRANS_TYPE = 1 AND
    (
        creditAccount.EXTERNAL_ID IN ('600070','240040','DLL_Tills Acc','600080','600090','600050','600100','330260') 
        OR debitAccount.EXTERNAL_ID IN ('600070','240040','DLL_Tills Acc','600080','600090','600050','600100','330260')
    )
UNION ALL
SELECT
    act.center||'acc'||act.id||'tr'||act.subid                  AS Account_Trans_Id,
    COALESCE(cnl.center||'cn'||cnl.id||'ln'||cnl.subid, il.center||'inv'||il.id||'ln'||il.subid) AS invoice_or_credit_id,    
    COALESCE(cnl.person_center||'p'||cnl.person_id, il.person_center||'p'||il.person_id, ar.customercenter||'p'||ar.customerid)     AS member_id,
    COALESCE(art.text,act.text)                                 AS Description,
    longtodatec(act.trans_time, act.center)                     AS Datetime,
    act.amount                           AS amount,
    pr.name                              AS product_name,
    CASE act.TRANS_TYPE WHEN 1 THEN 'GeneralLedger' WHEN 2 THEN 'AccountReceivable' WHEN 3 THEN 'AccountPayable' WHEN 4 THEN 'InvoiceLine' WHEN 5 THEN 'CreditNoteLine' WHEN 6 THEN 'BillLine' ELSE 'Undefined' END AS TRANS_TYPE,
    COALESCE(sac.name,sac_cl.name)                      AS "Ledger Group",
    COALESCE(sac.external_id,sac_cl.external_id)        AS "Ledger Group Code",    
    creditAccount.name                                  AS Credit_Account,
    creditAccount.EXTERNAL_ID                           AS Credit_Account_ExternalID,
    debitAccount.name                                   AS Debit_Account,
    debitAccount.external_id                            AS Debit_Account_ExternalID
FROM
    ACCOUNT_TRANS act
JOIN
    params
ON
    params.id = act.center
    AND act.TRANS_TIME >= params.fromts
    AND act.TRANS_TIME < params.toTs
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
    AR_TRANS art
ON
    art.ref_type = 'ACCOUNT_TRANS'
    AND act.center = art.ref_center
    AND act.id = art.ref_id
    AND act.subid = art.ref_subid    
LEFT JOIN
    account_receivables ar
ON
    art.center = ar.center
    AND art.id = ar.id        
LEFT JOIN 
    credit_note_lines_mt cnl 
ON 
    cnl.account_trans_center = act.center 
    and cnl.account_trans_id = act.id 
    and cnl.account_trans_subid = act.subid 
LEFT JOIN
    invoice_lines_mt il 
ON 
   (il.ACCOUNT_TRANS_CENTER = act.CENTER AND il.ACCOUNT_TRANS_ID = act.ID AND il.ACCOUNT_TRANS_SUBID = act.SUBID ) 
   OR 
   (cnl.invoiceline_center = il.center AND cnl.invoiceline_id = il.id and cnl.invoiceline_subid = il.subid)
LEFT JOIN
   products pr ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID    
LEFT JOIN
   product_account_configurations prac
ON
   prac.id = pr.product_account_config_id
LEFT JOIN
   accounts sac
ON
    sac.globalid = prac.sales_account_globalid
    AND sac.center = pr.center   
LEFT JOIN
   products prod_cl
ON
   prod_cl.center = cnl.productcenter
   AND prod_cl.id = cnl.productid
LEFT JOIN
   product_account_configurations prac_cl
ON
   prac_cl.id = prod_cl.product_account_config_id
LEFT JOIN
   accounts sac_cl
ON
   sac_cl.globalid = prac_cl.sales_account_globalid
   AND sac_cl.center = prod_cl.center    
WHERE
   act.TRANS_TYPE > 1 AND
    (
        creditAccount.EXTERNAL_ID IN ('600070','240040','DLL_Tills Acc','600080','600090','600050','600100','330260') 
        OR debitAccount.EXTERNAL_ID IN ('600070','240040','DLL_Tills Acc','600080','600090','600050','600100','330260')
    )

    
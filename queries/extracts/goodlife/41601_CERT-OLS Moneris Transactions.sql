-- The extract is extracted from Exerp on 2026-02-08
-- Reviewed in https://clublead.atlassian.net/browse/ST-16327
WITH accounts_less AS (

    SELECT

    center
    ,id
    ,external_id

    FROM

    accounts

    WHERE
    
    external_id IN (
        '0023-20715-000' -- API Sales
        ,'12700-000' -- Account Receivables - Member
        ,'0023-99995-000' -- Inter-Club Transactions
        -- ,'65300-100' -- Cash Register Interim
        -- ,'46000-000' -- PT Starter Package
        -- ,'40000-000' -- PAP Membership
        -- ,'40300-000' -- PIF Membership
    )

), account_trans_temp AS (

SELECT  

 acctx.center
  ,acctx.id
  ,acctx.subid
  ,acctx.aggregated_transaction_center
  ,acctx.aggregated_transaction_id
  ,acctx.amount
  ,ar.customercenter
    ,ar.customerid
    ,art.employeecenter
    ,art.employeeid
    ,art.text
    ,art.entry_time
    -- ,art.amount

   FROM ar_trans art 

   
   
    JOIN   account_trans acctx
    ON art.ref_center = acctx.center
    AND art.ref_id = acctx.id
    AND art.ref_subid = acctx.subid
    AND art.ref_type = 'ACCOUNT_TRANS'
    AND acctx.info_type = 11
    AND art.employeecenter = 990
    AND art.entry_time BETWEEN
        CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000+18000000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000+18000000
    AND acctx.entry_time BETWEEN
        CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000+18000000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000+18000000
    

    JOIN accounts_less ax
    ON acctx.credit_accountcenter = ax.center
    AND acctx.credit_accountid = ax.id
    -- AND ax.external_id = '0023-20715-000'

    JOIN accounts_less ax2
    ON acctx.debit_accountcenter = ax2.center
    AND acctx.debit_accountid = ax2.id
    -- AND ax2.external_id = '12700-000'

    JOIN account_receivables ar
    ON ar.center = art.center
    AND ar.id = art.id


),arSubList AS (

    SELECT

        art.center
        ,art.id
        ,art.trans_time
        ,art.info
        ,art.text
        ,art.employeecenter
        ,art.employeeid
        ,art.amount
        ,art.ref_type
        ,art.ref_center
        ,art.ref_id
        ,CASE
            WHEN art.ref_subid IS NULL
            THEN 0
            ELSE art.ref_subid
        END as ref_subid
    
    FROM

    subscription_sales ss

    JOIN account_receivables ar
    ON ar.customercenter = ss.owner_center
    AND ar.customerid = ss.owner_id

    JOIN ar_trans art
    ON art.center = ar.center
    AND art.id = ar.id

    WHERE

    ss.employee_center = 990
    AND ss.employee_id IN (228,5601,56802)
    AND ss.sales_date BETWEEN :Transaction_Start_Date AND :Transaction_End_Date
    AND ss.type = 1 -- NEW
    AND art.employeecenter = 990
    AND art.employeeid IN (228,5601,56802)
    AND art.trans_time BETWEEN
        CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000+18000000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000+18000000
        AND art.text LIKE '%API%'

), InvoiceSubList AS (

    SELECT
    
        art.ref_type
        ,art.ref_center
        ,art.ref_id
        ,0 AS ref_subid
        ,inv.text
        ,inv.total_amount * -1 AS total_amount
        ,acct.aggregated_transaction_center
        ,acct.aggregated_transaction_id
		,acct.center
		,acct.id
		,acct.subid
    
    
    FROM
    
        arSubList art
    
    JOIN invoice_lines_mt inv
        ON art.ref_center = inv.center
        AND art.ref_id = inv.id
        AND art.ref_type = 'INVOICE'

    JOIN account_trans acct
        ON inv.account_trans_center = acct.center
        AND inv.account_trans_id = acct.id
        AND inv.account_trans_subid = acct.subid

), CreditSubList AS (

    SELECT
    
        art.ref_type
        ,art.ref_center
        ,art.ref_id
        ,0 AS ref_subid
        ,cred.text
        ,cred.total_amount
        ,acct.aggregated_transaction_center
        ,acct.aggregated_transaction_id
    		,acct.center
		,acct.id
		,acct.subid

    FROM
    
        arSubList art
    
    JOIN credit_note_lines_mt cred
        ON art.ref_center = cred.center
        AND art.ref_id = cred.id
        AND art.ref_type = 'CREDIT_NOTE'
    
    JOIN account_trans acct
        ON cred.account_trans_center = acct.center
        AND cred.account_trans_id = acct.id
        AND cred.account_trans_subid = acct.subid

), AccountTransSubList AS (

    SELECT
    
        art.ref_type
        ,art.ref_center
        ,art.ref_id
        ,art.ref_subid
        ,art.text
        ,art.amount AS total_amount
        ,acct.aggregated_transaction_center
        ,acct.aggregated_transaction_id
		,acct.center
		,acct.id
		,acct.subid

    
    FROM
    
        arSubList art

    JOIN account_trans acct
        ON art.ref_center = acct.center
        AND art.ref_id = acct.id
        AND art.ref_subid = acct.subid
        AND art.ref_type = 'ACCOUNT_TRANS'

), AggSubList AS (

        SELECT
    
            *
    
        FROM
    
            InvoiceSubList
    
    UNION
    
        SELECT
    
            *
    
        FROM
    
            CreditSubList
    
    UNION
    
        SELECT
    
            *
    
        FROM
    
            AccountTransSubList

)



    SELECT

        art.center AS Center
        ,TO_CHAR(longtodateC(art.trans_time, art.center), 'YYYY-MM-dd HH24:MI') AS TransactionTime
	,art.ref_type AS type
        ,art.info AS OrderNumber
        ,substring(art.info from 8 for 10) AS InvoiceNumber
		,substring(art.info from 16 for 10) AS InvoiceNumber
        ,ag.text
        ,ag.total_amount
        ,ar.customercenter || 'p' || ar.customerid AS Customerid
        ,p.fullname AS CustomerName
        ,art.employeecenter || 'emp' || art.employeeid AS Employeeid
        ,ep.fullname AS EmployeeName
        ,art.amount AS Amount
        ,ag.aggregated_transaction_center || 'agt' || ag.aggregated_transaction_id AS AggregatedTransactionId
        ,ag.center || 'acc' || ag.id || 'tr' || ag.subid AS transaction_id

    FROM 

        arSubList art

    JOIN account_receivables ar
        ON art.center = ar.center
        AND art.id = ar.id

    JOIN Employees e
        ON e.center = art.employeecenter
        AND e.id = art.employeeid

    JOIN Persons ep
        ON ep.center = e.personcenter
        AND ep.id = e.personid

    JOIN Persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
        
    JOIN AggSubList ag
        USING (ref_type,ref_center,ref_id, ref_subid)

UNION

    SELECT

        crt.center AS Center
        ,TO_CHAR(longtodateC(crt.transtime, crt.center), 'YYYY-MM-dd HH24:MI') AS TransactionTime
        ,TEXT 'Cash Register Transaction' AS Type
        ,crt.coment AS OrderNumber
        ,substring(crt.coment from 8 for 10) AS InvoiceNumber
        ,substring(
            regexp_replace(acct.text, '^[A-Za-z: #]*', '')
            from 16 for 10) AS InvoiceNumber
        ,NULL
        ,crt.amount
        ,crt.customercenter || 'p' || crt.customerid AS Customerid
        ,p.fullname AS CustomerName
        ,crt.employeecenter || 'emp' || crt.employeeid AS Employeeid
        ,ep.fullname AS EmployeeName
        ,crt.amount AS Amount
        ,acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id AS AggregatedTransactionId
,acct.center || 'acc' || acct.id || 'tr' || acct.subid AS transaction_id

    FROM 

        cashregistertransactions crt

    JOIN account_trans acct
        ON crt.gltranscenter = acct.center
        AND crt.gltransid = acct.id
        AND crt.gltranssubid = acct.subid
        AND acct.info_type = 6
        AND crt.center = 990
        AND crt.config_payment_method_id = 9 -- API SALES Payment Method
        AND crt.transtime BETWEEN
           CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000+18000000 
           AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000+18000000

    JOIN persons p
        ON crt.customercenter = p.center
        AND crt.customerid = p.id

    JOIN employees e
        ON crt.employeecenter = e.center
        AND crt.employeeid = e.id

    JOIN persons ep
        ON e.personcenter = ep.center
        AND e.personid = ep.id

UNION
SELECT

        acct.center AS Center
        ,TO_CHAR(longtodateC(acct.entry_time, acct.center), 'YYYY-MM-dd HH24:MI') AS TransactionTime
        ,TEXT 'ACCOUNT_TRANS' AS Type
		,regexp_replace(acct.text, '^[A-Za-z: #]*', '')
		AS OrderNumber
        -- ,art.text AS OrderNumber
        ,substring(
            regexp_replace(acct.text, '^[A-Za-z: #]*', '')
            from 8 for 10) AS InvoiceNumber
        ,substring(
            regexp_replace(acct.text, '^[A-Za-z: #]*', '')
            from 16 for 10) AS InvoiceNumber
        ,NULL
        ,acct.amount
        ,p.center || 'p' || p.id AS Customerid
        ,p.fullname AS CustomerName
        ,acct.employeecenter || 'emp' || acct.employeeid AS Employeeid
        ,ep.fullname AS EmployeeName
        ,acct.amount AS Amount
        ,acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id AS AggregatedTransactionId
        ,acct.center || 'acc' || acct.id || 'tr' || acct.subid AS transaction_id

    FROM 

    account_trans_temp acct    

    JOIN persons p
    ON acct.customercenter = p.center
    AND acct.customerid = p.id

    JOIN employees e
    ON acct.employeecenter = e.center
    AND acct.employeeid = e.id

    JOIN persons ep
    ON e.personcenter = ep.center
    AND e.personid = ep.id

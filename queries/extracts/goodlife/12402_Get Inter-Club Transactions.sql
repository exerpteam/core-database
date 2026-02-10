-- The extract is extracted from Exerp on 2026-02-08
--  
WITH init_trans_one AS (

    SELECT 

        actr.aggregated_transaction_center
        ,actr.aggregated_transaction_id
        ,actr.amount
        ,actr.center
        ,actr.credit_accountcenter
        ,actr.credit_accountid
        ,actr.debit_accountcenter
        ,actr.debit_accountid
        ,actr.debit_transaction_center
        ,actr.debit_transaction_id
        ,actr.debit_transaction_subid
        ,actr.entry_time
        ,actr.id
        ,actr.subid
        ,actr.text
        ,actr.trans_time

    FROM 

        account_trans actr

    WHERE

        actr.center = $$Center$$ 
        AND actr.subid = $$Transaction_ID$$

    LIMIT 1
    
), init_trans_two AS (
    
    SELECT 

        actr.aggregated_transaction_center
        ,actr.aggregated_transaction_id
        ,actr.amount
        ,actr.center
        ,actr.credit_accountcenter
        ,actr.credit_accountid
        ,actr.debit_accountcenter
        ,actr.debit_accountid
        ,actr.debit_transaction_center
        ,actr.debit_transaction_id
        ,actr.debit_transaction_subid
        ,actr.entry_time
        ,actr.id
        ,actr.subid
        ,actr.text
        ,actr.trans_time

    FROM 

        account_trans actr

    WHERE

        actr.debit_transaction_center = $$Center$$ 
        AND actr.debit_transaction_subid = $$Transaction_ID$$
        AND NOT EXISTS (
        
            SELECT
            
            1
            
            FROM
            
            init_trans_one    
        
        )
        

    LIMIT 1
    
), second_trans_one  AS (

    SELECT

        actr.aggregated_transaction_center
        ,actr.aggregated_transaction_id
        ,actr.amount
        ,actr.center
        ,actr.credit_accountcenter
        ,actr.credit_accountid
        ,actr.debit_accountcenter
        ,actr.debit_accountid
        ,actr.debit_transaction_center
        ,actr.debit_transaction_id
        ,actr.debit_transaction_subid
        ,actr.entry_time
        ,actr.id
        ,actr.subid
        ,actr.text
        ,actr.trans_time

    FROM

        init_trans_one i

    JOIN  account_trans actr
    ON i.debit_transaction_center = actr.center
    AND i.debit_transaction_subid = actr.subid

    LIMIT 1
    
), second_trans_two  AS (

    SELECT

        i.aggregated_transaction_center
        ,i.aggregated_transaction_id
        ,i.amount
        ,i.center
        ,i.credit_accountcenter
        ,i.credit_accountid
        ,i.debit_accountcenter
        ,i.debit_accountid
        ,i.debit_transaction_center
        ,i.debit_transaction_id
        ,i.debit_transaction_subid
        ,i.entry_time
        ,i.id
        ,i.subid
        ,i.text
        ,i.trans_time

    FROM

        init_trans_two i

    JOIN  account_trans actr
    ON i.debit_transaction_center = actr.center
    AND i.debit_transaction_subid = actr.subid

    LIMIT 1
    
), all_trans AS (

    SELECT
    
         aggregated_transaction_center
        ,aggregated_transaction_id
        ,amount
        ,center
        ,credit_accountcenter
        ,credit_accountid
        ,debit_accountcenter
        ,debit_accountid
        ,debit_transaction_center
        ,debit_transaction_id
        ,debit_transaction_subid
        ,entry_time
        ,id
        ,subid
        ,text
        ,trans_time
    
    FROM
    
        init_trans_one
    
     UNION
    
    SELECT
    
         aggregated_transaction_center
        ,aggregated_transaction_id
        ,amount
        ,center
        ,credit_accountcenter
        ,credit_accountid
        ,debit_accountcenter
        ,debit_accountid
        ,debit_transaction_center
        ,debit_transaction_id
        ,debit_transaction_subid
        ,entry_time
        ,id
        ,subid
        ,text
        ,trans_time
    
    FROM
    
        second_trans_one
    
     UNION
    
    SELECT
    
         aggregated_transaction_center
        ,aggregated_transaction_id
        ,amount
        ,center
        ,credit_accountcenter
        ,credit_accountid
        ,debit_accountcenter
        ,debit_accountid
        ,debit_transaction_center
        ,debit_transaction_id
        ,debit_transaction_subid
        ,entry_time
        ,id
        ,subid
        ,text
        ,trans_time
    
    FROM
    
        second_trans_two
    
    UNION
    
    SELECT
    
         aggregated_transaction_center
        ,aggregated_transaction_id
        ,amount
        ,center
        ,credit_accountcenter
        ,credit_accountid
        ,debit_accountcenter
        ,debit_accountid
        ,debit_transaction_center
        ,debit_transaction_id
        ,debit_transaction_subid
        ,entry_time
        ,id
        ,subid
        ,text
        ,trans_time
    
    FROM
    
        init_trans_two
    
)

    SELECT

        TO_DATE(TO_CHAR(longtodateC(a.trans_time, 100), 'YYYY-MM-dd HH24:MI'),'YYYY-MM-dd HH24:MI') AS transtime
        ,TO_DATE(TO_CHAR(longtodateC(a.entry_time, 100), 'YYYY-MM-dd HH24:MI'),'YYYY-MM-dd HH24:MI') AS entrytime
        ,a.center
        ,a.id
        ,a.subid
        ,a.aggregated_transaction_center||'agt'||a.aggregated_transaction_id AS Aggregated_Transaction_ID
        ,a.text
        ,a.amount
        ,dac.name AS Debit_Account_Name
        ,dac.external_id AS Debit_Account_Great_Plains_ID
        ,dac.center||'acc'||dac.id AS Debit_Account_Exerp_ID
        ,cac.name AS Credit_Account_Name
        ,cac.external_id AS Credit_Account_Great_Plains_ID
        ,cac.center||'acc'||cac.id AS Credit_Account_Exerp_ID
        ,a.debit_transaction_center
        ,a.debit_transaction_id
        ,a.debit_transaction_subid
    
    FROM

        all_trans a

    JOIN accounts cac
    ON a.credit_accountcenter = cac.center
    AND a.credit_accountid = cac.id

    JOIN accounts dac
    ON a.debit_accountcenter = dac.center
    AND a.debit_accountid = dac.id

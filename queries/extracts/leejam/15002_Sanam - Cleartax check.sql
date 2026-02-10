-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        *
FROM                
        (    
        SELECT
                inv.center AS center , 
                inv.id     AS id , 
                inv.center||'inv'||inv.id as transactionID,
                inv.clearance_status AS cleartax_status,
                inv.payer_center||'p'|| inv.payer_id as personID
        FROM
            invoices inv    
        UNION ALL      
        SELECT
                cn.center AS center , 
                cn.id     AS id ,
                cn.center||'cred'||cn.id as transactionID,
                cn.clearance_status AS cleartax_status,
                cn.payer_center ||'p'|| cn.payer_id as personID 
        FROM
            credit_notes cn
        )t   
WHERE
        t.transactionID IN (:TransactionID)
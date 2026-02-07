WITH
          params AS MATERIALIZED
          (
                SELECT
                        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                        c.id AS CENTER_ID,
                        datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1 AS ToDate
                FROM
                        centers c
         ),
         invoices AS
         (
                SELECT
                        inv.center
                        ,inv.id
                        ,inv.payer_center
                        ,inv.payer_id
                        ,inv.trans_time
                        ,invl.reason
                FROM
                        invoices inv
                JOIN
                        leejam.invoice_lines_mt invl
                        ON invl.center = inv.center
                        AND invl.id = inv.id
                WHERE 
                        invl.reason NOT IN (6,8,7,36)
        ),
        credit_notes AS
        (
                SELECT
                        cn.center
                        ,cn.id
                        ,cn.payer_center
                        ,cn.payer_id
                        ,cn.trans_time
                        ,cnl.reason
                FROM
                        leejam.credit_notes cn
                JOIN
                        leejam.credit_note_lines_mt cnl
                        ON cnl.center = cn.center
                        AND cnl.id = cn.id
                WHERE 
                        cnl.reason NOT IN (6,8,7,36)
        )        
SELECT 
        p.center||'p'||p.id CompanyID
        ,p.lastname AS Company_name
        ,longtodatec(art.trans_time,art.center) AS trans_date
        ,-art.amount AS Amount
        ,art.due_date
        ,art.text
        ,art.status
        ,inv.center||'inv'||inv.id AS transaction_no        
FROM 
        account_receivables ar
JOIN
        ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
JOIN
        persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
JOIN
        invoices inv
                ON inv.center = art.ref_center
                AND inv.id = art.ref_id
                AND art.ref_type = 'INVOICE'  
JOIN
        params
                ON params.center_id = art.center                                                             
WHERE
        p.center||'p'||p.id IN (:personID)
        AND
        art.trans_time BETWEEN params.FromDate and params.ToDate 
        AND
        art.status != 'CLOSED'
UNION ALL
SELECT 
        p.center||'p'||p.id CompanyID
        ,p.lastname AS Company_name
        ,longtodatec(art.trans_time,art.center) AS trans_date
        ,-art.amount AS Amount
        ,art.due_date
        ,art.text
        ,art.status
        ,cn.center||'cred'||cn.id AS transaction_no  
FROM  
        account_receivables ar
JOIN
        ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
JOIN
        persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
JOIN
        credit_notes cn
                ON cn.center = art.ref_center
                AND cn.id = art.ref_id
                AND art.ref_type = 'CREDIT_NOTE'
JOIN
        params
                ON params.center_id = art.center                                                             
WHERE
        p.center||'p'||p.id IN (:personID)
        AND
        art.trans_time BETWEEN params.FromDate and params.ToDate
        AND
        art.status != 'CLOSED'  
UNION ALL
SELECT 
        p.center||'p'||p.id CompanyID
        ,p.lastname AS Company_name
        ,longtodatec(art.trans_time,art.center) AS trans_date
        ,-art.amount AS Amount
        ,art.due_date
        ,art.text
        ,art.status
        ,act.center||'account_trans'||act.id AS transaction_no  
FROM 
        account_receivables ar
JOIN
        ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
JOIN
        persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
JOIN
        leejam.account_trans act
                ON act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid
                AND art.ref_type = 'ACCOUNT_TRANS'  
JOIN
        params
                ON params.center_id = art.center                                                             
WHERE
        p.center||'p'||p.id IN (:personID)
        AND
        art.trans_time BETWEEN params.FromDate and params.ToDate
        AND
        art.status != 'CLOSED'                                  
        
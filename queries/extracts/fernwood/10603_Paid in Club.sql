-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        CAST(longtodatec(art.entry_time,art.center) AS Date) AS "Payment Date"
        ,art.amount AS "Amount paid (Gross)"
        ,ROUND(art.amount*0.1,2) AS "GST" 
        ,p.fullname AS "Member Name"
        ,p.center ||'p'||p.id AS "Person ID"
        ,c.shortname AS "Center Name"
        ,art.text AS "Description"
        ,pemp.fullname AS "Employee Name"
        ,pemp.center ||'p'||pemp.id as "Employee Person ID"
        ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid AS "Transaction ID"        
FROM
        ar_trans art
JOIN
        art_match artm
                ON artm.art_paying_center = art.center
                AND artm.art_paying_id = art.id
                AND artm.art_paying_subid = art.subid
                AND artm.cancelled_time IS NULL        
JOIN
        account_receivables ar
                ON ar.center = art.center
                AND ar.id = art.id
JOIN
        persons p
                ON p.center = ar.customercenter                      
                AND p.id = ar.customerid                                                               
JOIN
        centers c
                ON c.id = p.center
LEFT JOIN
        employees emp
                ON emp.center = art.employeecenter
                AND emp.id = art.employeeid
LEFT JOIN
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid                
WHERE
        art.ref_type in ('ACCOUNT_TRANS','CREDIT_NOTE')
        AND 
        (art.text like '%recouped%'
        or 
        art.text like 'FreeCre%'
        or 
        art.text like 'PartialCre%'
        or 
        art.text like 'Manual registered payment of reques%'
        or 
        art.text = 'Payment for sale'
        or
        art.text = 'Payment into account'
        or
        art.text like 'Creditnot%'
		or
		art.text like 'Debt payment%')
        AND p.center in (:Scope)
        AND art.entry_time BETWEEN datetolongC(TO_CHAR(to_date(:DateStart, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),art.center) 
        AND datetolongC(TO_CHAR(to_date(:DateEnd, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),art.center) + 86400 * 1000  
        AND 
        art.employeecenter is not null 
        AND    
        art.employeecenter||'emp'||art.employeeid != '100emp1'                             
UNION ALL
SELECT 
        pr.req_date AS "Payment Date"
        ,pr.req_amount AS "Amount paid"
        ,ROUND(pr.req_amount*0.1,2) AS "GST" 
        ,p.fullname AS "Member Name"
        ,p.center ||'p'|| p.id AS "PersonID"
        ,c.shortname AS "Center Name"
        ,'Representation' AS "Description"
        ,'N/A' AS "Employee Name"
        ,'N/A' AS "Employee Person ID"
        ,'N/A' AS "Transaction ID"
FROM 
        payment_requests  pr
JOIN
        account_receivables ar
        ON ar.center = pr.center 
        AND ar.id = pr.id
JOIN
        persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid  
JOIN
        centers c
        ON c.id = p.center              
where 
        pr.request_type = 6
        AND 
        pr.state = 3
        AND
        pr.req_date Between :DateStart and :DateEnd
        AND
        p.Center in (:Scope)
UNION ALL
SELECT DISTINCT
        CAST(longtodatec(art.entry_time,art.center) AS Date) AS "Payment Date"
        ,art.amount AS "Amount paid (Gross)"
        ,ROUND(art.amount*0.1,2) AS "GST" 
        ,p.fullname AS "Member Name"
        ,p.center ||'p'||p.id AS "Person ID"
        ,c.shortname AS "Center Name"
        ,art.text AS "Description"
        ,pemp.fullname AS "Employee Name"
        ,pemp.center ||'p'||pemp.id as "Employee Person ID"
        ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid AS "Transaction ID"        
FROM
        ar_trans art
JOIN
        art_match artm
                ON artm.art_paying_center = art.center
                AND artm.art_paying_id = art.id
                AND artm.art_paying_subid = art.subid
                AND artm.cancelled_time IS NULL        
JOIN
        account_receivables ar
                ON ar.center = art.center
                AND ar.id = art.id
JOIN
        persons p
                ON p.center = ar.customercenter                      
                AND p.id = ar.customerid                                                               
JOIN
        centers c
                ON c.id = p.center
LEFT JOIN
        employees emp
                ON emp.center = art.employeecenter
                AND emp.id = art.employeeid
LEFT JOIN
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid                
WHERE
        art.ref_type = 'ACCOUNT_TRANS'
        AND p.center in (:Scope)
        AND art.entry_time BETWEEN datetolongC(TO_CHAR(to_date(:DateStart, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),art.center) 
        AND datetolongC(TO_CHAR(to_date(:DateEnd, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),art.center) + 86400 * 1000  
        AND art.employeecenter||'emp'||art.employeeid = '100emp2202' 
        AND art.text != 'API Sale Transaction'        

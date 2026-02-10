-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
     PARAMS AS MATERIALIZED
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE-8 AS DATE), 'YYYY-MM-dd'),c.time_zone) AS FROM_DATE,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE AS DATE), 'YYYY-MM-dd'),c.time_zone) AS TO_DATE
        FROM
            centers c
               
            )
SELECT DISTINCT
        t."Payment Date"
        ,t."Amount"
        ,t."Member Name"
        ,t."Person ID"
        ,t."Center Name"
        ,t."Description"
        ,t."Employee Name" 
FROM
        (
                SELECT DISTINCT
                        CAST(longtodatec(art.entry_time,art.center) AS Date) AS "Payment Date"
                        ,art.amount AS "Amount"
                        ,p.fullname AS "Member Name"
                        ,p.center ||'p'||p.id AS "Person ID"
                        ,c.shortname AS "Center Name"
                        ,art.text AS "Description"
                        ,pemp.fullname AS "Employee Name"     
                FROM
                        ar_trans art
                cross join params        
                        
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
                        art.text like 'Automatic placement%'
                        or
                        art.text like 'Creditnot%'
						or
						art.text like 'Debt payment%')
                        AND p.center in (:Scope)
                        AND art.entry_time > params.FROM_DATE
                        --AND art.entry_time < params.TO_DATE    
                        AND 
                        art.employeecenter is not null 
                        AND    
                        art.employeecenter||'emp'||art.employeeid != '100emp1'                             
                UNION ALL
                SELECT distinct 
                        pr.req_date AS "Payment Date"
                        ,pr.req_amount AS "Amount paid"
                        ,p.fullname AS "Member Name"
                        ,p.center ||'p'|| p.id AS "PersonID"
                        ,c.shortname AS "Center Name"
                        ,'Representation' AS "Description"
                        ,'N/A' AS "Employee Name"
                FROM 
                        payment_requests  pr
                cross join params        
                        
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
                        datetolongtz(TO_CHAR(pr.req_date , 'YYYY-MM-DD HH24:MI'),c.time_zone) BETWEEN params.FROM_DATE AND params.TO_DATE
                        AND
                        p.Center in (:Scope)            
                UNION ALL
                SELECT DISTINCT
                        CAST(longtodatec(act.trans_time,act.center) AS Date) AS "Payment Date"
                        ,act.amount AS "Amount"
                        ,p.fullname AS "Member Name"
                        ,p.center ||'p'||p.id AS "Person ID"
                        ,c.shortname AS "Center Name"
                        ,act.text AS "Description"
                        ,pemp.fullname AS "Employee Name"   
                FROM
                        account_trans act 
                cross join params
                        
                JOIN
                        ar_trans art
                        ON art.ref_center = act.center
                        AND art.ref_id = act.id
                        AND art.ref_subid = act.subid 
                JOIN
                        account_receivables ar
                        ON ar.center = art.center
                        AND ar.id = art.id   
                JOIN
                        persons p
                        ON p.center = ar.customercenter                      
                        AND p.id = ar.customerid 
                JOIN
                        employees emp
                        ON emp.center = art.employeecenter
                        AND emp.id = art.employeeid
                JOIN
                        persons pemp
                        ON pemp.center = emp.personcenter
                        AND pemp.id = emp.personid                                  
                JOIN
                        centers c
                        ON c.id = act.center        
                WHERE
                        act.trans_type = 2
                        AND
                        act.info_type = 23
                        AND
                        art.ref_type = 'ACCOUNT_TRANS' 
                        AND 
                        p.center in (:Scope)
                        AND 
                        art.entry_time > params.FROM_DATE
        )t                        
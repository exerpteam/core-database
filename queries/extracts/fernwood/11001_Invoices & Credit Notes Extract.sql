-- The extract is extracted from Exerp on 2026-02-08
-- Extract Showing Invoices & Credit Notes Raised
https://clublead.atlassian.net/browse/ST-13744
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT DISTINCT  
        CAST(longtodatec(inv.trans_time,inv.center) AS Date) AS "Transaction Date"
        ,ar.amount AS "Amount"
        ,p.fullname AS "Member Name"
        ,p.center ||'p'||p.id AS "Person ID"
        ,c.shortname AS "Center Name"
        ,ar.text AS "Description"
        ,pemp.fullname AS "Employee Name"
        ,pemp.center ||'p'||pemp.id as "Employee Person ID"
        ,ar.ref_center||'inv'||ar.ref_id AS "Transaction ID"  
FROM
        invoices inv
JOIN
        ar_trans ar
                ON inv.center = ar.ref_center
                AND inv.id = ar.ref_id
JOIN
        persons p
                ON p.center = inv.payer_center
                AND p.id = inv.payer_id
JOIN
        centers c
                ON c.id = p.center   
JOIN
        employees emp
                ON emp.center = ar.employeecenter
                AND emp.id = ar.employeeid
JOIN
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid 
JOIN    params 
        ON params.CENTER_ID = p.center                                                                             
WHERE             
       ar.employeecenter is not null 
       AND
       ar.amount != 0
       AND 
       p.center in (:Scope)
       AND 
       inv.trans_time BETWEEN params.FromDate AND params.ToDate         
UNION ALL
SELECT DISTINCT
        CAST(longtodatec(art.entry_time,art.center) AS Date) AS "Transaction Date"
        ,art.amount AS "Amount"
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
JOIN
        employees emp
                ON emp.center = art.employeecenter
                AND emp.id = art.employeeid
JOIN
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid   
JOIN    params 
        ON params.CENTER_ID = p.center                              
WHERE
        art.ref_type in ('ACCOUNT_TRANS','CREDIT_NOTE')
        AND 
        art.employeecenter is not null 
        AND
        art.amount != 0
        AND    
        art.employeecenter||'emp'||art.employeeid != '100emp1'  
        AND 
        p.center in (:Scope)
        AND 
        art.entry_time BETWEEN params.FromDate AND params.ToDate 
Order by 1,4
                           

                     


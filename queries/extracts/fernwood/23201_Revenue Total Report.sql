-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-6947
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
        ar.customercenter||'p'||ar.customerid AS "PersonID"
        ,c.name AS "Club Name"
        ,ch.name AS "Clearing House"
        ,inv.center||'inv'||inv.id AS "Invoice No"
        ,longtodatec(inv.trans_time,inv.center) AS "Invoice Date"
        ,longtodatec(payment.entry_time,payment.art_paid_center) AS "Settlement Date"
        ,pr.req_date AS "Payment Request Date"
        ,payment.amount  
FROM
        account_receivables ar
JOIN
        ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
                AND art.ref_type = 'ACCOUNT_TRANS' 
JOIN
        art_match payment
                ON payment.art_paying_center = art.center
                AND payment.art_paying_id = art.id
                AND payment.art_paying_subid = art.subid
JOIN       
        ar_trans armatch
                ON payment.art_paid_center = armatch.center
                AND payment.art_paid_id = armatch.id
                AND payment.art_paid_subid = armatch.subid
JOIN
        invoice_lines_mt invl
                ON invl.center = armatch.ref_center
                AND invl.id = armatch.ref_id
JOIN
        invoices inv
                ON invl.center = inv.center
                AND invl.id = inv.id
JOIN
        payment_request_specifications prs
                ON prs.center = armatch.payreq_spec_center  
                AND prs.id = armatch.payreq_spec_id
                AND prs.subid = armatch.payreq_spec_subid
                AND prs.cancelled IS FALSE
JOIN
        payment_requests pr 
                ON prs.center = pr.inv_coll_center 
                AND prs.id = pr.inv_coll_id 
                AND prs.subid = pr.inv_coll_subid 
JOIN 
        clearinghouses ch 
                ON ch.id = pr.clearinghouse_id   
JOIN 
        centers c 
                ON c.id = pr.center 
JOIN
        params
                ON params.center_id = c.id                                                                                
WHERE
        armatch.collected IN (1,2)
        AND
        payment.entry_time BETWEEN params.FromDate AND params.ToDate 
        AND 
        c.id IN (:Scope)                   
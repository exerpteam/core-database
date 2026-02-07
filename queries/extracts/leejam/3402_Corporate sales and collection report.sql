SELECT DISTINCT
        t1."Company id"
        ,t1."Company name"
        ,t1."Account manager"
        ,t1."Parent company"
        ,t1."Invoice number"
        ,t1."Invoice date"
        ,t1."Invoice amount ex VAT"
        ,t1."VAT"
        ,t1."Total invoice amount"
        ,t1."Total amount due"
        ,t1."Due date"
        ,t1."Amount paid"
        ,t1."Receipt number"
        ,t1."Receipt date"        
FROM
        (               
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
                p.center||'p'||p.id AS "Company id"
                ,p.fullname AS "Company name"
                ,emppam.fullname AS "Account manager"
                ,ppart.fullname AS "Parent company"
                ,prs.ref AS "Invoice number"
                ,TO_CHAR(longtodateC(pr.entry_time,pr.center),'YYYY-MM-dd') AS "Invoice date"
                ,prs.total_invoice_amount - (prs.total_invoice_amount * 0.1304) AS "Invoice amount ex VAT"
                ,prs.total_invoice_amount * 0.1304 AS "VAT"
                ,prs.total_invoice_amount AS "Total invoice amount"
                ,prs.open_amount AS "Total amount due"
                ,art.due_date AS "Due date"
                ,pr.xfr_amount AS "Amount paid"
                ,CASE
                        WHEN payment.ref_type = 'ACCOUNT_TRANS' THEN payment.ref_center||'account_trans'||payment.ref_id
                        WHEN payment.ref_type = 'CREDIT_NOTE' THEN payment.ref_center||'cred'||payment.ref_id 
                END AS "Receipt number"
                ,TO_CHAR(longtodateC(prs.paid_state_last_entry_time,payment.center),'YYYY-MM-dd HH24:MI') AS "Receipt date"
        FROM 
                invoices inv
        JOIN
                persons p
                        ON p.center = inv.payer_center        
                        AND p.id = inv.payer_id
                        AND p.persontype = 4
        JOIN
                invoice_lines_mt invl
                        ON invl.center = inv.center
                        AND invl.id = inv.id
        LEFT JOIN
                relatives part
                        ON part.relativecenter = p.center
                        AND part.relativeid = p.id
                        AND part.rtype = 6 
                        AND part.status = 1 
                        AND (part.expiredate IS NULL OR part.expiredate > Current_Date)
        LEFT JOIN
                persons ppart
                        ON ppart.center = part.center
                        AND ppart.id = part.id
                        and ppart.persontype = 4                 
        JOIN
                ar_trans art
                        ON art.ref_center = inv.center
                        AND art.ref_id = inv.id
                        AND art.ref_type = 'INVOICE'
        JOIN
                payment_request_specifications prs
                        ON prs.center = art.payreq_spec_center 
                        AND prs.id = art.payreq_spec_id
                        AND prs.subid = art.payreq_spec_subid
        JOIN
                payment_requests pr
                        ON pr.inv_coll_center = prs.center
                        AND pr.inv_coll_id = prs.id
                        AND pr.inv_coll_subid = prs.subid
        JOIN      
                art_match armatch
                        ON armatch.art_paid_center = art.center
                        AND armatch.art_paid_id = art.id
                        AND armatch.art_paid_subid = art.subid                              
        JOIN
                ar_trans payment
                        ON payment.center = armatch.art_paying_center
                        AND payment.id = armatch.art_paying_id                
                        AND payment.subid = armatch.art_paying_subid
        LEFT JOIN
                account_trans act
                        ON act.center = payment.ref_center
                        AND act.id = payment.ref_id
                        AND act.subid = payment.ref_subid             
        LEFT JOIN
                credit_notes cn
                        ON cn.center = payment.ref_center
                        AND cn.id = payment.ref_id                                
        JOIN
                relatives AccountMGR
                        ON AccountMGR.center = p.center
                        AND AccountMGR.id = p.id
                        AND AccountMGR.rtype = 10
                        AND AccountMGR.status = 1
                        AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)
        JOIN
                employees empam
                        ON empam.center = AccountMGR.relativecenter
                        AND empam.id = AccountMGR.relativeid
        JOIN
                persons emppam
                        ON emppam.center = empam.personcenter
                        AND emppam.id = empam.personid
        JOIN 
                params 
                        ON params.CENTER_ID = p.center                 
        WHERE
                pr.req_date BETWEEN :From AND :To
        UNION ALL
        SELECT  
                p.center||'p'||p.id AS "Company id"
                ,p.fullname AS "Company name"
                ,emppam.fullname AS "Account manager"
                ,ppart.fullname AS "Parent company"
                ,prs.ref AS "Invoice number"
                ,TO_CHAR(longtodateC(pr.entry_time,pr.center),'YYYY-MM-dd') AS "Invoice date"
                ,prs.total_invoice_amount - (prs.total_invoice_amount * 0.1304) AS "Invoice amount ex VAT"
                ,prs.total_invoice_amount * 0.1304 AS "VAT"
                ,prs.total_invoice_amount AS "Total invoice amount"
                ,prs.open_amount AS "Total amount due"
                ,art.due_date AS "Due date"
                ,pr.xfr_amount AS "Amount paid"
                ,CASE
                        WHEN payment.ref_type = 'ACCOUNT_TRANS' THEN payment.ref_center||'account_trans'||payment.ref_id
                        WHEN payment.ref_type = 'CREDIT_NOTE' THEN payment.ref_center||'cred'||payment.ref_id 
                END AS "Receipt number"
                ,TO_CHAR(longtodateC(prs.paid_state_last_entry_time,payment.center),'YYYY-MM-dd HH24:MI') AS "Receipt date"
        FROM 
                credit_notes cn
        JOIN
                persons p
                        ON p.center = cn.payer_center       
                        AND p.id = cn.payer_id
                        AND p.persontype = 4
        JOIN
                ar_trans payment
                        ON cn.center = payment.ref_center
                        AND cn.id = payment.ref_id
        LEFT JOIN      
                art_match armatch
                        ON payment.center = armatch.art_paying_center
                        AND payment.id = armatch.art_paying_id                
                        AND payment.subid = armatch.art_paying_subid
        LEFT JOIN
                ar_trans art                          
                        ON armatch.art_paid_center = art.center
                        AND armatch.art_paid_id = art.id
                        AND armatch.art_paid_subid = art.subid
                        AND art.ref_type = 'INVOICE'                              
        LEFT JOIN
                invoices inv
                        ON art.ref_center = inv.center
                        AND art.ref_id = inv.id                               
        JOIN
                invoice_lines_mt invl
                        ON invl.center = inv.center
                        AND invl.id = inv.id
        LEFT JOIN
                relatives part
                        ON part.relativecenter = p.center
                        AND part.relativeid = p.id
                        AND part.rtype = 6 
                        AND part.status = 1 
                        AND (part.expiredate IS NULL OR part.expiredate > Current_Date)
        LEFT JOIN
                persons ppart
                        ON ppart.center = part.center
                        AND ppart.id = part.id
                        and ppart.persontype = 4                 
        JOIN
                payment_request_specifications prs
                        ON prs.center = art.payreq_spec_center 
                        AND prs.id = art.payreq_spec_id
                        AND prs.subid = art.payreq_spec_subid
        JOIN
                payment_requests pr
                        ON pr.inv_coll_center = prs.center
                        AND pr.inv_coll_id = prs.id
                        AND pr.inv_coll_subid = prs.subid                                          
        JOIN
                relatives AccountMGR
                        ON AccountMGR.center = p.center
                        AND AccountMGR.id = p.id
                        AND AccountMGR.rtype = 10
                        AND AccountMGR.status = 1
                        AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)
        JOIN
                employees empam
                        ON empam.center = AccountMGR.relativecenter
                        AND empam.id = AccountMGR.relativeid
        JOIN
                persons emppam
                        ON emppam.center = empam.personcenter
                        AND emppam.id = empam.personid
        JOIN 
                params 
                        ON params.CENTER_ID = p.center                 
        WHERE
                cn.entry_time BETWEEN params.FromDate AND params.ToDate               
        UNION ALL            
        SELECT  
                p.center||'p'||p.id AS "Company id"
                ,p.fullname AS "Company name"
                ,emppam.fullname AS "Account manager"
                ,ppart.fullname AS "Parent company"
                ,prs.ref AS "Invoice number"
                ,TO_CHAR(longtodateC(pr.entry_time,pr.center),'YYYY-MM-dd') AS "Invoice date"
                ,prs.total_invoice_amount - (prs.total_invoice_amount * 0.1304) AS "Invoice amount ex VAT"
                ,prs.total_invoice_amount * 0.1304 AS "VAT"
                ,prs.total_invoice_amount AS "Total invoice amount"
                ,prs.open_amount AS "Total amount due"
                ,art.due_date AS "Due date"
                ,pr.xfr_amount AS "Amount paid"
                ,CASE
                        WHEN payment.ref_type = 'ACCOUNT_TRANS' THEN payment.ref_center||'account_trans'||payment.ref_id
                        WHEN payment.ref_type = 'CREDIT_NOTE' THEN payment.ref_center||'cred'||payment.ref_id 
                END AS "Receipt number"
                ,TO_CHAR(longtodateC(prs.paid_state_last_entry_time,payment.center),'YYYY-MM-dd HH24:MI') AS "Receipt date"
        FROM 
                account_trans act
        JOIN
                ar_trans payment
                        ON act.center = payment.ref_center
                        AND act.id = payment.ref_id
                        AND act.subid = payment.ref_subid
        JOIN
                art_match armatch  
                        ON payment.center = armatch.art_paying_center
                        AND payment.id = armatch.art_paying_id                
                        AND payment.subid = armatch.art_paying_subid                              
        JOIN      
                ar_trans art        
                        ON armatch.art_paid_center = art.center
                        AND armatch.art_paid_id = art.id
                        AND armatch.art_paid_subid = art.subid                              
        JOIN
                invoices inv
                        ON art.ref_center = inv.center
                        AND art.ref_id = inv.id
                        AND art.ref_type = 'INVOICE'                        
        JOIN
                persons p
                        ON p.center = inv.payer_center        
                        AND p.id = inv.payer_id
                        AND p.persontype = 4
        JOIN
                invoice_lines_mt invl
                        ON invl.center = inv.center
                        AND invl.id = inv.id
        LEFT JOIN
                relatives part
                        ON part.relativecenter = p.center
                        AND part.relativeid = p.id
                        AND part.rtype = 6 
                        AND part.status = 1 
                        AND (part.expiredate IS NULL OR part.expiredate > Current_Date)
        LEFT JOIN
                persons ppart
                        ON ppart.center = part.center
                        AND ppart.id = part.id
                        and ppart.persontype = 4                 
        JOIN
                payment_request_specifications prs
                        ON prs.center = art.payreq_spec_center 
                        AND prs.id = art.payreq_spec_id
                        AND prs.subid = art.payreq_spec_subid 
        JOIN
                payment_requests pr
                        ON pr.inv_coll_center = prs.center
                        AND pr.inv_coll_id = prs.id
                        AND pr.inv_coll_subid = prs.subid                                                      
        JOIN
                relatives AccountMGR
                        ON AccountMGR.center = p.center
                        AND AccountMGR.id = p.id
                        AND AccountMGR.rtype = 10
                        AND AccountMGR.status = 1
                        AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)
        JOIN
                employees empam
                        ON empam.center = AccountMGR.relativecenter
                        AND empam.id = AccountMGR.relativeid
        JOIN
                persons emppam
                        ON emppam.center = empam.personcenter
                        AND emppam.id = empam.personid
        JOIN 
                params 
                        ON params.CENTER_ID = p.center                 
        WHERE
                act.entry_time BETWEEN params.FromDate AND params.ToDate               
        )t1                         
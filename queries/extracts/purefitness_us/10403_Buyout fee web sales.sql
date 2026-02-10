-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id) AS BIGINT) AS fromDateLong,
                                CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD'),c.id) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                          
            where  c.country = 'US'  and ((c.id in (:scope)) or (c.id = 100)) )
 SELECT  
                       
                         payer.center || 'p' || payer.id AS Person_Id,
                         payer.fullname as name,
                     --   longToDateC(i.trans_time, i.center) AS salestime,
                        case
                       when cnl.center is not null
                       then sum(cnl.total_amount)
                       else '0'  
                                            
                       END  as refund,
                        
                        'Sales list' AS payment_type,
                        crt.coment as "Transaction text",
                        i.center,
                        sum(il.total_amount) as payment,
                       longToDateC(i.entry_time, i.center) AS salestime,
                         i.text AS "type"
                        
                         
                        
                        
                        
                        
                        
                FROM invoice_lines_mt il
                JOIN params par
                        ON par.center_id = il.center
                JOIN invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                      
                JOIN persons payer
                        ON payer.center = i.payer_center
                        AND payer.id = i.payer_id
                JOIN cashregistertransactions crt
                        ON crt.paysessionid = i.paysessionid
                JOIN persons cp
                        ON payer.current_person_center  = cp.center
                        AND payer.current_person_id = cp.id
                JOIN account_trans act
                                ON act.center = crt.gltranscenter
                                 AND act.id = crt.gltransid 
                                 AND act.subid = crt.gltranssubid
         join ACCOUNTS acc

ON
    
        act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id

left join creditcardtransactions cct
                on i.center = cct.invoice_center and
                i.id = cct.invoice_id       
 
 left join credit_note_lines_mt cnl
 on
 il.center = cnl.invoiceline_center
 and       
 il.id = cnl.invoiceline_id
 and
 il.subid = cnl.invoiceline_subid  
and cnl.reason not in (6) 
      
             
                                 
                                         
                WHERE
                        il.total_amount != 0 and      
                        i.entry_time >= par.fromDateLong
                        AND i.entry_time <= par.toDateLong
                        and crt.coment is not null
                        and i.text = 'Web sale: Buyout Fee'
             group by 
             payer.fullname,
             payer.center || 'p' || payer.id,
             longToDateC(i.trans_time, i.center),
             i.entry_time,
             cct.transaction_id,
             i.center,
             crt.coment,
             i.text,
             acc.name,
             act.debit_accountcenter,
             cnl.center
            
             
                                  
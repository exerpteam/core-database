-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        total.*
        
FROM
(
        WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           JOIN
             AREA_CENTERS ac
             on
             ac.center = c.id
             join AREAS a
             on
           ac.area = a.id
          and a.root_area = 1
       and a.id not in (6,4)
       and a.blocked != 'true'
            where ac.area in (7,8)        
                                        and c.country = 'CH'  and ((c.id in ($$scope$$)) or (c.id = 100)) 
                          
                ),
                
        find_request AS MATERIALIZED
        (
        
                SELECT
                        art_list.*
                        ,MIN(pr.req_date) as pr_paid_for
                FROM
                (
                        SELECT
                                art.center,
                                art.id,
                                art.subid
                        FROM persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN account_receivables ar 
                                ON p.center = ar.customercenter AND p.id = ar.customerid
                        JOIN ar_trans art
                                ON ar.center = art.center AND ar.id = art.id
                        JOIN persons cp
                                        ON p.current_person_center  = cp.center
                                        AND p.current_person_id = cp.id
                        LEFT JOIN  creditcardtransactions cct
                        ON
                                art.center = cct.gl_trans_center
                                AND art.id = cct.gl_trans_id
                                AND art.subid = cct.gl_trans_subid
                                AND cct.method = 4
                        LEFT JOIN account_trans act
                                ON act.center = Art.ref_center
                                 AND act.id = art.ref_id 
                                 AND act.subid = art.ref_subid
                                 AND art.ref_type = 'ACCOUNT_TRANS'
                        WHERE
                                ar.ar_type = 4
                                AND art.entry_time between par.fromDateLong AND par.toDateLong
                                AND art.amount != 0
                                AND art.ref_type = 'ACCOUNT_TRANS'
                              
                ) art_list
                LEFT JOIN art_match artm
                        ON artm.art_paying_center = art_list.center
                        AND artm.art_paying_id = art_list.id
                        AND artm.art_paying_subid = art_list.subid
                LEFT JOIN ar_trans art2
                        ON art2.center = artm.art_paid_center
                        AND art2.id = artm.art_paid_id
                        AND art2.subid = artm.art_paid_subid
                left join payment_request_specifications prs2
                        ON prs2.center = art2.payreq_spec_center
                        AND prs2.id = art2.payreq_spec_id
                        AND prs2.subid = art2.payreq_spec_subid
                left join payment_requests pr
                        ON prs2.center = pr.inv_coll_center
                        AND prs2.id = pr.inv_coll_id
                        AND prs2.subid = pr.inv_coll_subid
                GROUP BY       
                        art_list.center,
                        art_list.id,
                        art_list.subid
        )
        SELECT
                r1.*
        FROM
        (
                -- NO PAYMENT ACCOUNT
                SELECT  
                       
                        longToDateC(i.trans_time, i.center) AS datetime,
                        CAST('Cash receipts: Adyen web sales' AS TEXT) AS account,
                       case
                       when art.amount < 0
                       then art.amount
                       else '0'  
                                            
                       END  as refund,
                        payer.fullname as name,
                        'Sales list' AS payment_type,
                        crt.coment as "Transaction text",
                        payer.center || 'p' || payer.id AS Person_Id,
                        i.center,
                        sum(il.total_amount) as payment,
                        longToDateC(i.entry_time, i.center) AS entry_time,
                         trim(leading 'Verkauf neuer Mitgliedschaft:' from i.text) AS "type"
                        
                        
                        
                        
                        
                FROM invoice_lines_mt il
                JOIN params par
                        ON par.center_id = il.center
                JOIN invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                left join creditcardtransactions cct
                on i.center = cct.invoice_center and
                i.id = cct.invoice_id       
                LEFT JOIN ar_trans art
                        ON art.ref_center = i.center
                        AND art.ref_id = i.id
                        AND art.ref_type = 'INVOICE'
                LEFT JOIN persons payer
                        ON payer.center = i.payer_center
                        AND payer.id = i.payer_id
                LEFT JOIN cashregistertransactions crt
                        ON crt.paysessionid = i.paysessionid
                LEFT JOIN persons cp
                        ON payer.current_person_center  = cp.center
                        AND payer.current_person_id = cp.id
                WHERE
                        -- anadir condicion from and to respecto a una columna de tiempo
                        il.net_amount != '0'
                        AND art.center IS NULL
                        AND i.entry_time >= par.fromDateLong
                        AND i.entry_time <= par.toDateLong
                        and crt.coment is not null
             group by 
             payer.fullname,
             payer.center || 'p' || payer.id,
             longToDateC(i.trans_time, i.center),
             i.entry_time,
             cct.transaction_id,
             i.center,
             art.amount,
             crt.coment,
             i.text
                        
                        
        ) r1
      
       UNION ALL
        SELECT 
                r3.*
        FROM
        (
              Select distinct  
                       longToDateC(act.TRANS_TIME, art.center) AS datetime, 
                        CAST('Cash receipts: Adyen web sales' AS TEXT) AS account,
                       case
                       when art.amount < 0
                       then art.amount
                       else '0'  
                                            
                       END  as refund,
                        p.fullname as name,
                        'Debt payment' AS payment_type,
                      trim(replace(t1.TEXT,'Debt payment',''))  as "Transaction text",
                        ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS Person_Id,
                       p.CENTER,
                        CASE
        WHEN (art.amount>0)
        THEN art.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    longToDateC(act.ENTRY_TIME, art.center) AS entry_time,
                    
                        CAST('Debt payment' AS TEXT) AS "type"
                        
                   
   
   
FROM ACCOUNT_TRANS act

join params
on params.center_id = act.center


left JOIN
    AR_TRANS art
ON
  art.REF_TYPE = 'ACCOUNT_TRANS'
  and   art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid


join ACCOUNTS acc

ON
    (
        act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id )
    OR (
        act.CREDIT_ACCOUNTCENTER = acc.center
        AND act.CREDIT_ACCOUNTID = acc.id )
--and acc.GLOBALID IN ('AR_EXTERNALDEBT',
--'AR_PAYMENT_PERSONS')
and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6733' and acc.external_id !='6735' and acc.external_id !='6735' and acc.external_id != '6741' and acc.external_id !='0001' and acc.external_id != '1299'
   

left JOIN
    ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = art.CENTER
    AND AR.ID = ART.ID
left JOIN
    PERSONS P
ON
    P.CENTER = AR.CUSTOMERCENTER
    AND P.ID = AR.CUSTOMERID
    and p.center in (params.center_id)
left join

(
Select
act2.text, 
acc2.name                                                                       AS account,
acc2.external_id,
act2.entry_time,
act2.credit_accountcenter,
act2.credit_accountid,
act2.amount


from ACCOUNT_TRANS act2

join params
on params.center_id = act2.center

join ACCOUNTS acc2
ON
    (
        act2.DEBIT_ACCOUNTCENTER = acc2.center
        AND act2.DEBIT_ACCOUNTID = acc2.id )
    OR (
       act2.CREDIT_ACCOUNTCENTER = acc2.center
        and act2.CREDIT_ACCOUNTID = acc2.id )       
and acc2.external_id != '6791' and acc2.external_id !='9999' and acc2.external_id != '0001' and acc2.external_id != '6791' and acc2.external_id != '6301' and acc2.external_id != '1299' and acc2.external_id != 'ERROR'
and act2.text != 'Payment: Converted subscription invoice' and acc2.external_id !='1254'
where
act2.TRANS_TIME >= params.fromDatelong  
AND act2.TRANS_TIME < params.toDatelong
 )t1    

on
act.entry_time-250 < t1.entry_time
and act.entry_time+750 > t1.entry_time
and act.amount = t1.amount              

where    
act.TRANS_TIME >=  params.fromDateLong 
AND act.TRANS_TIME < params.toDateLong 
and acc.external_id != '0001'
and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6733' and acc.external_id !='6735' and acc.external_id != '6741' and acc.external_id != '1299' and t1.external_id != '1299'
 and acc.external_id != '6743' and acc.external_id != '6736' and acc.external_id != '6701' and acc.external_id != '6764' and t1.external_id != '6301' and t1.external_id != '0001' and t1.text != 'Payment: Converted subscription invoice' and t1.text != 'Write off' and t1.external_id != '1299'
 and  ar.center in (params.center_ID) and t1.text not like 'REFPC;%%' and t1.text not like 'Regret%%' and t1.text not like 'Transfer to payment account for payment request%%' and t1.text not like 'Lastschrifteinzug%%' and t1.text not like 'Einzahlung aufs Konto%%'
and t1.TEXT not like 'Write off%%'
and act.info_type not in  (3,4,5)-- and art.employeecenter = 100 and art.employeeid = 415
--and ((art.text = 'API Register remaining money from payment request') or (art.text ='Cash collection payment received') or (art.text ='Online betaling') or (art.employeecenter = 100)) 
and act.AMOUNT != 0
 and act.entry_TIME >= params.fromDatelong  
AND act.entry_TIME < params.toDateLong 
        ) r3
       
        
) total
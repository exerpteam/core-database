-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where  c.country = 'SE'and c.id = 584  )







SELECT distinct
                    entrytime,
                    text,               
                     debitexternal,
                     creditexternal,
                    amount,
                    book_date,
                   aggrtransid,
                   memberid,
                   TRANS_TYPE,
                   Transid    
                FROM
                    (
                        SELECT
                            deb.external_id as debitexternal,
                            cred.external_id as creditexternal,
                            act.CENTER,
                            act.DEBIT_ACCOUNTCENTER accountcenter,
                            act.DEBIT_ACCOUNTID accountid,
                            act.AMOUNT amount,
                            TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD') book_date,
                            longtodate(act.entry_TIME) entrytime,
                            act.text as text,
                            act.aggregated_transaction_center ||'agt'|| act.aggregated_transaction_id as aggrtransid,
                            case when act.trans_type = 2
                            then ar.customercenter ||'p'|| ar.customerid 
                            when act.trans_type = 5
                            then credl.person_center ||'p'|| credl.person_id
                            Else invl.person_center ||'p'|| invl.person_id  end as Memberid,
                            CASE act.TRANS_TYPE WHEN 1 THEN 'GeneralLedger' WHEN 2 THEN 'AccountReceivable' WHEN 3 THEN 'AccountPayable' WHEN 4 THEN 'InvoiceLine' WHEN 5 THEN 'CreditNoteLine' WHEN 6 THEN 'BillLine' ELSE 'Undefined' END AS TRANS_TYPE,
act.center||'acc'||act.id ||'tr'|| act.subid as Transid
                        FROM
                            ACCOUNT_TRANS act
                            join params par     
                           on
                           par.center_id = act.center
                            JOIN ACCOUNTS deb
        ON
            act.debIT_ACCOUNTCENTER = deb.CENTER
            AND act.debIT_ACCOUNTID = deb.ID
            
             JOIN ACCOUNTS cred
        ON
            act.CREDIT_ACCOUNTCENTER = cred.CENTER
            AND act.CREDIT_ACCOUNTID = cred.ID
        left join ar_trans art
        on
        art.ref_center = act.center
        and
        art.ref_id = act.id
        and 
        art.ref_subid = act.subid
       and art.ref_type = 'ACCOUNT_TRANS'
        left join account_receivables ar
        on art.center = ar.center
        and art.id = ar.id
        left join invoice_lines_mt invl
        on
        invl.account_trans_center = act.center
        and
        invl.account_trans_id = act.id
        and
        invl.account_trans_subid = act.subid
       left join credit_note_lines_mt credl
        on
        credl.account_trans_center = act.center
        and
        credl.account_trans_id = act.id
        and
        credl.account_trans_subid = act.subid 
        
        --left join    
            
            
                        WHERE
                            act.CENTER = par.center_id
                            AND act.TRANS_TIME >= par.fromDateLong
                            AND act.TRANS_TIME < par.toDateLong 
                            --AND act.TRANSFERRED = 1 
                            and ( (deb.external_id = '2890') or (cred.external_id = '2890'))
                            
                            )
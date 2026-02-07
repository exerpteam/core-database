WITH
    params AS materialized
    (
        SELECT
            c.id                                                                          AS center,
			datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE
		--	datetolongc(TO_CHAR(to_date(${to_date}$, 'YYYY-MM-DD HH24:MI:SS')+1,'YYYY-MM-DD HH24:MI:SS'), c.id)-1 AS TO_DATE
        FROM
            centers c
    )
    
    SELECT
    t4.member,
    t4.installment_plan_id,
    longtodateTZ(art_full2.entry_time, 'America/Toronto') AS entrytime,
    art_full2.due_date                                    AS installment_due,
    art_full2.amount,
    art_full2.unsettled_amount,
    art_full2.text
--    ,
--    art_full2.*
    
FROM    
    
     (-------------------------- t4 start
    ---- This query looks for credit note transactions that on the same date has a corresponding API Refund Transaction, and then excludes them
   SELECT
   t3.member,
 
to_char(longtodateTZ(art_4cred.entry_time, 'America/Toronto'), 'YYYY-MM-DD HH24:MI') as cr_entry_time_min, 
to_char(longtodateTZ(art_4cred.entry_time, 'America/Toronto'), 'YYYY-MM-DD HH24:MI') as api_entry_time_min,    
longtodateTZ(art_4cred.entry_time, 'America/Toronto') as cr_entry_time,
longtodateTZ(art_4api.entry_time, 'America/Toronto') as api_entry_time,
art_4cred.amount as cr_amount,
art_4api.amount as api_amount,
art_4cred.text as cr_text,
art_4api.text as api_text,
art_4cred.center, 
art_4cred.id,
art_4cred.installment_plan_id
    
FROM
    
    
    
    ( ----------------------------------------t3 start
    --------------- This query identifies installment plans with a positive balance a second time    
    SELECT
                    t2.member,
                    art_3.installment_plan_id,
                    SUM(art_3.amount) AS positive_balance_for_camp,
                    art_3.center,
                    art_3.id
    from
    
    ( ----------------------------------------t2 start
    --------------- This query pulls all transactions for camps identified in t1 in order to exclude the ones 
      --------------- that have 2 or less transactions (the normal debit and credit or just the initial debit)
        SELECT
            t1.member,
            t1.installment_plan_id,
            t1.center,
            t1.id,
            COUNT (art_full.entry_time)
        FROM
            (----------------------------------------t1 start 
            -------- This query identifies installment plans with a positive balance, 
              -------- but will have false positives for camps purchased before Jan 1 but paid after Jan 1
                SELECT
                    ar.customercenter||'p'||ar.customerid AS member,
                    art.installment_plan_id,
                    SUM(amount) AS positive_balance_for_camp,
                    art.center,
                    art.id
                FROM
                params
                join
                    ACCOUNT_RECEIVABLES ar on params.center = ar.center
                JOIN ar_trans art ON ar.center = art.center AND ar.id = art.id AND ar.ar_type = 6
                  WHERE
                    ar.ar_type = 6
--                    AND art.center = 15
--                    AND art.id = 100832
                AND art.entry_time >= params.from_date
                --AND art.entry_time >= datetolongTZ('2023-04-01 01:00','America/Toronto')
                GROUP BY
                    ar.customercenter||'p'||ar.customerid,
                    art.installment_plan_id,
                    art.center,
                    art.id
                HAVING
                    SUM(amount) > 0 ) t1
       ----------------------------------------t1 end
        LEFT JOIN
            ar_trans art_full ON t1.center = art_full.center AND t1.id = art_full.id AND t1.installment_plan_id = art_full.installment_plan_id
        GROUP BY
            t1.member,
            t1.installment_plan_id,
            t1.center,
            t1.id
        HAVING
            COUNT (art_full.entry_time) > 2 ) t2
        ----------------------------------------    t2 end
        
        left join ar_trans art_3 on t2.center = art_3.center and t2.id = art_3.id AND t2.installment_plan_id = art_3.installment_plan_id 
        GROUP BY
                   t2.member,
                    art_3.installment_plan_id,
                    art_3.center,
                    art_3.id
                HAVING
                    SUM(amount) > 0 ) t3
        ----------------------------------------    t3 end                    
        
        left join ar_trans art_4cred on t3.center = art_4cred.center and t3.id = art_4cred.id and art_4cred.text like 'FreeCreditNote%' AND t3.installment_plan_id = art_4cred.installment_plan_id
       left join ar_trans art_4api on t3.center = art_4api.center and t3.id = art_4api.id and art_4api.text = 'API Refund Transaction' and  to_char(longtodateTZ(art_4cred.entry_time, 'America/Toronto'), 'YYYY-MM-DD HH24:MI') = to_char(longtodateTZ(art_4cred.entry_time, 'America/Toronto'), 'YYYY-MM-DD HH24:MI')
   WHERE

art_4api.center is null ) t4
          
        ----------------------------------------    t4 end
        
LEFT JOIN ar_trans art_full2 ON t4.center = art_full2.center AND t4.id = art_full2.id AND t4.installment_plan_id = art_full2.installment_plan_id          
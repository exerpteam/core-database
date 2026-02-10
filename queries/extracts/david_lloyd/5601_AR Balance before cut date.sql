-- The extract is extracted from Exerp on 2026-02-08
-- Excluding ANNUAL membership
WITH PARAMS as Materialized
(
   select 
      id ,
       CAST(DATE_TRUNC('month', CAST($$cut_date$$ AS DATE) - INTERVAL '1 month') AS DATE) AS first_day_of_previous_month,
       CAST(DATE_TRUNC('month', CAST($$cut_date$$ AS DATE)) AS DATE) AS first_day_of_selected_month,
       CAST(datetolongc(TO_CHAR(DATE_TRUNC('month', CAST($$cut_date$$ AS DATE) - INTERVAL '1 month'), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS  fromts,
       CAST(datetolongc(TO_CHAR(DATE_TRUNC('month', CAST($$cut_date$$ AS DATE)), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS  tots
   FROM
      centers    
   WHERE id in ($$scope$$)
)
,
v_per_trans AS
    (   SELECT  DISTINCT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            p.fullname,
            p.status,
            case when p.sex = 'C' then 'COMPANY' else 'MEMBER' end as DebtorType,
            p.external_id,
            art.trans_time,
            art.entry_time,
            art.CENTER,
            art.id, 
            art.unsettled_amount,
            art.amount,
            ar.balance,
            ar.AR_TYPE,
            art.due_date
        FROM
            params
        JOIN    
            persons p
        ON
            params.id = p.center    
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            p.center = ar.CUSTOMERCENTER
        AND p.id = ar.CUSTOMERID
       -- AND ar.balance < 0
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
        AND art.ID = ar.ID
        AND ar.ar_type = 4
        LEFT JOIN
            account_receivables pag
        ON
            pag.customercenter = p.center
        AND pag.customerid = p.id
        AND pag.AR_TYPE = 4
--        LEFT JOIN
--        credit_note_lines_mt cl
--        ON
--        cl.center = art.ref_center
--    AND cl.id = art.ref_id
    --AND art.ref_type = 'CREDIT_NOTE'
    LEFT JOIN
        invoice_lines_mt il
    ON
        il.center = art.ref_center
    AND il.id = art.ref_id
    AND art.ref_type = 'INVOICE'
        WHERE
           --art.trans_time < params.tots
           --AND
            art.text != 'Legacy Debt'
            --ar.AR_TYPE = 4        
           -- AND ar.customerid = 409 -- in (2917, 4112, 429, 9934, 1553, 7421) 
    AND NOT EXISTS 
    (select 1 from product_and_product_group_link pl   
      WHERE pl.product_group_id = 401
      and pl.product_center = il.productcenter
      AND pl.product_id = il.productid
      ) -- Annual    
)    
SELECT
    t.CUSTOMERCENTER ||'p'|| t.CUSTOMERID AS PERSON_ID,
    t.DebtorType as DebtorType,
    t.fullname AS PERSON_NAME,
    t.CUSTOMERCENTER                      AS center,
    ROUND(LEAST( 
    SUM(
    CASE
        WHEN (t.trans_time < params.tots AND t.trans_time >= params.fromts) 
        AND (t.due_date is null OR t.due_date < params.first_day_of_selected_month)  
        THEN t.amount ELSE 0 
    END),0), 2) 
    as balance_at_the_end 
--    SUM(
--    CASE
--        WHEN t.trans_time < params.tots AND t.trans_time >= params.fromts THEN t.amount ELSE 0 
--    END    
--    ) as balance_at_time_only,    
--    SUM(
--    CASE
--        WHEN t.trans_time < params.tots THEN t.amount ELSE 0 
--    END    
--    ) as balance_at_time_total,
--    SUM(
--    CASE
--        WHEN (t.trans_time < params.tots) 
--        AND (t.due_date is null OR (t.due_date >= params.fromDate AND t.due_date < params.toDate))  
--        THEN t.amount ELSE 0 
--    END    
--    ) as balance_just_after_period2,
--    SUM(
--    CASE
--        WHEN (t.trans_time < params.tots) 
--        AND (t.due_date is null OR t.due_date < params.toDate)  
--        THEN t.amount ELSE 0 
--    END    
--    ) as balance_just_after_period3,    
--    sum(t.amount) as balance_now
 from 
   params 
 JOIN
 v_per_trans t
 ON params.id = t.customercenter
GROUP BY
    t.CUSTOMERCENTER,
    t.CUSTOMERID,
    t.fullname,
    t.DebtorType,
    t.external_id,
    t.STATUS,
    t.AR_TYPE

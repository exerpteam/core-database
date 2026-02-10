-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE($$fromdate$$, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE($$todate$$, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where  c.country = 'SE'  and c.id in ($$scope$$))


select distinct

longtodate(transtime) "Time of Sales",
credit.name as "Credit Acoount",
debit.name as "Debit account",
prod.name as product,
 invl.net_amount as "Net Amount",
 crt.center, 
params.center_name,
customercenter ||'p'|| customerid as "Member ID",
crt.coment as "Benify ID",
act.aggregated_transaction_center ||'agt'|| aggregated_transaction_id as agtnumber

--crt.config_payment_method_id
 
 
 
 from CASHREGISTERTRANSACTIONS crt
 join params 
 on params.center_id = crt.center
 
 join invoices i
 on
 crt.PAYSESSIONID = i.PAYSESSIONID
 join INVOICE_LINES_MT invl
 on
 i.center = invl.center
 and
 i.id = invl.id
 and i.trans_time between fromDateLong and toDateLong
 join PRODUCTS prod
 ON
     prod.ID = invl.PRODUCTID
     AND prod.CENTER = invl.PRODUCTCENTER
 join PRODUCT_AND_PRODUCT_GROUP_LINK ppg
 on
 prod.center = ppg.PRODUCT_CENTER
 and
 prod.id = ppg.PRODUCT_ID
 join PRODUCT_GROUP pg
 on
 ppg.PRODUCT_GROUP_ID = pg.id

JOIN account_trans act
                                ON act.center = invl.account_trans_center
                                 AND act.id = invl.account_trans_id 
                                 AND act.subid = invl.account_trans_subid
join accounts debit
on
act.debit_accountcenter = debit.center
and
act.debit_accountid = debit.id

join accounts credit
on
act.credit_accountcenter = credit.center
and
act.credit_accountid = credit.id
 
 
 where
 crt.TRANSTIME between fromDateLong and toDateLong
 and
 crt.config_payment_method_id = 7
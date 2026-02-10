-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dataset AS materialized
    (
        SELECT
            ar.customercenter||'p'||ar.customerid                         AS "PersonID",
            pr.name                                                       AS "Buyout Fee",
art_pay.center||'ar'||art_pay.id||'art'||art_pay.subid        AS art_transaction,
            COALESCE(art_debt.unsettled_amount, art_pay.unsettled_amount) AS ds_unsettled_amount,
            COALESCE(art_paying_debt.REF_CENTER, art_paying.REF_CENTER)   AS art_paying_REF_CENTER,
            COALESCE(art_paying_debt.REF_id, art_paying.REF_id)           AS art_paying_REF_ID,
            COALESCE(art_paying_debt.REF_subid, art_paying.REF_subid)     AS art_paying_REF_SUBID,
            COALESCE(art_paying_debt.REF_type, art_paying.REF_type)       AS art_paying_REF_type,
            longtodatetz(art_pay.entry_time, 'America/New_York') as "Sales date and time",
            longtodatetz(art_paying.entry_time, 'America/New_York') as "Pay date and time",
            salep.fullname as "Sales employee",
            ivl.total_amount 
            
            
        FROM
            account_receivables ar
        JOIN
            ar_trans art_pay
        ON
            art_pay.CENTER=ar.CENTER
        AND art_pay.id=ar.ID
        JOIN
            invoice_lines_mt ivl
        ON
            art_pay.ref_center=ivl.center
        AND art_pay.ref_id=ivl.id
         
        JOIN invoices inv
        on inv.center = ivl.center
        and inv.id = ivl.id
                    
        JOIN  products pr
        ON
            pr.center=ivl.productcenter
        AND pr.id=ivl.productid
        LEFT JOIN
                         employees emp
                      ON
                         inv.EMPLOYEE_CENTER = emp.center
                         AND inv.EMPLOYEE_ID = emp.id
               LEFT JOIN
                         persons salep
                      ON
                         emp.personcenter = salep.center
                         AND emp.personid = salep.id        
        
        LEFT JOIN
            art_match am
        ON
            am.art_paid_center=art_pay.center
        AND am.art_paid_id=art_pay.id
        AND am.art_paid_subid=art_pay.subid
        LEFT JOIN
            ar_trans art_paying
        ON
            am.art_paying_center=art_paying.center
        AND am.art_paying_id=art_paying.id
        AND am.art_paying_subid=art_paying.subid
            --------moved to debt account-------------
        LEFT JOIN
            account_receivables ar_debt
        ON
            ar_debt.customercenter=ar.customercenter
        AND ar_debt.customerid=ar.customerid
        AND ar_debt.ar_type=5
        LEFT JOIN
            ar_trans art_debt
        ON
            art_debt.center=ar_debt.center
        AND art_debt.id=ar_debt.id
        AND art_debt.ref_center=art_paying.ref_center
        AND art_debt.ref_id=art_paying.ref_id
        AND art_debt.ref_subid=art_paying.ref_subid
        LEFT JOIN
            art_match am_debt
        ON
            am_debt.art_paid_center=art_debt.center
        AND am_debt.art_paid_id=art_debt.id
        AND am_debt.art_paid_subid=art_debt.subid
        LEFT JOIN
            ar_trans art_paying_debt
        ON
            am_debt.art_paying_center=art_paying_debt.center
        AND am_debt.art_paying_id=art_paying_debt.id
        AND am_debt.art_paying_subid=art_paying_debt.subid
        WHERE
            art_pay.ref_type = 'INVOICE'
        AND pr.name LIKE 'Buyout Fee%' 
        and art_pay.trans_time >= getstartofday((:start_date)::date::varchar, 100)  and art_pay.trans_time <= getendofday((:end_date)::date::varchar, 100)
        and ar.center in (:scope)
    )
--select * from dataset where "PersonID"='6006p1582';
SELECT distinct
    ds."PersonID",
    ds."Buyout Fee",
    ds.total_amount,
    CASE
        WHEN ds.ds_unsettled_amount!=0
        THEN 'Open'
        WHEN COALESCE(act.info_type, act_C.info_type) IN (7,5)
        THEN 'Written off'
        WHEN COALESCE(act.info_type, act_C.info_type) IN (23,
                                                          3,
                                                          11)
        THEN 'Paid'
        ELSE 'Not defined'
    END AS "Status",
    ds."Sales date and time",
  case
 WHEN COALESCE(act.info_type, act_C.info_type) IN (23,
                                                          3,
                                                          11)
then                                                   
   ds."Pay date and time"
   else null end as "Pay date and time",
   ds."Sales employee"
FROM
    dataset ds
    -------types of settling transactions----------
LEFT JOIN
    account_trans act
ON
    ds.art_paying_REF_CENTER = ACT.CENTER
AND ds.art_paying_REF_ID = ACT.ID
AND ds.art_paying_REF_SUBID = ACT.SUBID
AND ds.art_paying_REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN
    credit_note_lines_mt AS cl
ON
    ds.art_paying_REF_CENTER = cl.CENTER
AND ds.art_paying_REF_ID = cl.ID
AND cl.subid=1
AND ds.art_paying_REF_TYPE = 'CREDIT_NOTE'
LEFT JOIN
    account_trans act_c
ON
    cl.account_trans_center=act_c.center
AND cl.account_trans_id=act_c.id
AND cl.account_trans_subid=act_c.subid
GROUP BY
    ds."PersonID",
    ds."Buyout Fee",
    "Status",
    ds.art_transaction,
    ds."Sales date and time",
    ds."Pay date and time",
   act.info_type, 
   act_C.info_type,
   ds."Sales employee",
   ds.total_amount
order by ds."PersonID"
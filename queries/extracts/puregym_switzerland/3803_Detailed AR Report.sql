select
t1.*
from

(SELECT DISTINCT
    CASE AR_TYPE
        WHEN 1
        THEN 'Cash'
        WHEN 4
        THEN 'Payment'
        WHEN 5
        THEN 'Debt'
        WHEN 6
        THEN 'installment'
    END                                     AS AR_TYPE,
    ar.customercenter ||'p'|| ar.customerid AS memberid,
    ext.txtvalue                            AS OldmemberID,
    ar.balance                              AS "Current Balance",
    CASE
        WHEN ar.balance <> 0  and art.status IN ('OPEN','NEW')
        THEN art.amount
        ELSE null
    END AS
     "Open Transactions",
    art.unsettled_amount as "Open Amount",
    CASE
        WHEN i.text LIKE '%Converted subscription invoice%'
        THEN art.amount
    END AS "Converted Transactions",
    
       
    CASE
        WHEN ar.balance <> 0
        THEN art.text
        WHEN i.text LIKE '%Converted subscription invoice%'
        THEN art.text
    END AS "Text",
   i.text as "Conversion"
    
FROM
    ACCOUNT_RECEIVABLES AR
LEFT JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
LEFT JOIN
    person_ext_attrs ext
ON
    ext.personcenter = ar.customercenter
AND ext.personid = ar.customerid
AND ext.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    puregym_switzerland.invoices i
ON
    art.ref_center = i.center
AND art.ref_id = i.id
AND i.text LIKE '%Converted subscription invoice%'
WHERE

    ar.center IN (:scope)
    and art.trans_time <= getendofday((:cut_date)::date::varchar, 100)
    
     ) t1
        
        
        where t1."Current Balance" <> 0 and t1."Open Transactions" IS NOT NULL
;





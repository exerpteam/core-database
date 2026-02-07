WITH params AS MATERIALIZED
                (
                        SELECT
                                
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c 
                                           
           where  c.id in ($$scope$$)  )






SELECT distinct
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid, 
    ar.balance, 
CASE ar.AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' WHEN 6 THEN 'installment' END AS AR_TYPE,

    cc.amount as cc_amount,
    cc.CURRENTSTEP,
    cc.CURRENTSTEP_DATE,
    cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
    --s.end_date,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS

FROM 
PERSONS p 

join params
on
p.center = params.center_id

JOIN 
ACCOUNT_RECEIVABLES ar 
on   
p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID
--and ar.ar_type = 4

join CASHCOLLECTIONCASES cc    
on             
        ar.CUSTOMERCENTER = cc.PERSONCENTER
        and ar.CUSTOMERID = cc.PERSONID
        and cc.CURRENTSTEP = 1
         AND cc.CLOSED = 0

/*join
subscriptions s

on 
s.owner_center = p.center
and
s.owner_id = p.id*/

left Join Payment_agreements pa
ON
    ar.center = pa.center
AND ar.id = pa.id
and pa.active = 1

Where
ar.balance < 0
and cc.amount > 0
and cc.CURRENTSTEP = 1
--and ar.ar_type = 4


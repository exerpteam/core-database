-- This is the version from 2026-02-05
--  
SELECT distinct
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid, 
    ar.balance, 
    ar.ar_type,
    cc.amount as cc_amount,
    cc.CURRENTSTEP,
    cc.CURRENTSTEP_DATE,
    cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
    longToDate(cc.CLOSED_DATETIME) as Closedate,
--s.end_date,
CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS PASTATE,
pa.active
FROM 
PERSONS p 


JOIN 
ACCOUNT_RECEIVABLES ar 
on   
p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID

join CASHCOLLECTIONCASES cc    
on             
        ar.CUSTOMERCENTER = cc.PERSONCENTER
        and ar.CUSTOMERID = cc.PERSONID

join
subscriptions s

on 
s.owner_center = p.center
and
s.owner_id = p.id

left Join Payment_agreements pa
ON
    ar.center = pa.center
AND ar.id = pa.id
and pa.active = 1

Where
   (p.CENTER,p.id) IN (:member)
and cc.CASHCOLLECTIONSERVICE = '601'
and ar.balance < 0
and cc.amount > 0


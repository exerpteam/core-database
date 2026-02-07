-- This is the version from 2026-02-05
--  
SELECT DISTINCT
 P.CENTER ||'p'|| P.ID as memberid,
 P.FullNAME,
 pem.txtvalue as email,
 ar.balance Paymentaccount_balance,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
--pr.globalid,
--pr.name,
--CASE s.STATE  WHEN 2 THEN  'ACTIVE'  WHEN 3 THEN  'ENDED'  WHEN 4 THEN  'FROZEN'  WHEN 7 THEN  'WINDOW'  WHEN 8 THEN  'CREATED' ELSE 'OTHER' END AS "SUBSCRIPTION STATE",
--s.start_date as subscription_startdate,
a.center as agreement_center,
a.id as agreement_id,
A.subid as agreement_subid,
 A.state as agreement_state,
 A.ref as agreement_reference,
 CASE a.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END state
 
 
 FROM PERSONS P
 JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
 left join SUBSCRIPTIONS S ON  P.CENTER = S.OWNER_CENTER  AND P.ID = S.OWNER_ID
 LEFT join PRODUCTS PR 
	ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER AND PR.ID = S.SUBSCRIPTIONTYPE_ID
 left join relatives r on p.center = r.relativecenter and p.id = r.relativeid and r.rtype = 2
 left join person_ext_attrs pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email'
 left join person_ext_attrs pm on pm.personcenter = p.center and pm.personid = p.id and pm.name = '_eClub_PhoneSMS' 
left join payment_agreements A
on
ar.center = A.center and
ar.ID = A.id 

WHERE
p.CENTER in (:Center)  and
 --P.STATUS in (1,3) /*active + frozen */ and
 a.subid is NULL 
AND p.status not in (4,5,8)
and p.sex != 'C'
and p.persontype = 0
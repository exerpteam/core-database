SELECT DISTINCT
 pr.req_date,
pr.req_amount,
  pr.REQ_DELIVERY,
 P.CENTER ||'p'|| P.ID "Member Number",
 P.FULLNAME as "Member Name",
 P.LASTNAME as "Member Surname",
 pa2.bank_account_holder as "Account Holder Name",
 pa2.ref as "Exerp ref number",
 CASE pa2.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS PASTATE,
 longtodate(pa2.last_modified) as lastmodified,
 prod.name as "Subscription Name",
 CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription Status",
 CASE st.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'DD' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS "Subscription Type DD /Cash",
 CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
 FROM PERSONS P
 
left join ACCOUNT_RECEIVABLES ar
on 
ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id

left join payment_agreements A
 ON
    a.center = ar.center
AND a.id = ar.id

left JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id
left JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID
left JOIN
    CLEARINGHOUSES ch
ON
    a.CLEARINGHOUSE = ch.id
left JOIN
    CLEARINGHOUSES ch2
ON
    pa2.CLEARINGHOUSE = ch2.id
left JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    pa2.PAYMENT_CYCLE_CONFIG_ID = pcc.id
left join SUBSCRIPTIONS S ON  P.CENTER = S.OWNER_CENTER  AND P.ID = S.OWNER_ID
 left join relatives r on p.center = r.relativecenter and p.id = r.relativeid and r.rtype = 2
 left join person_ext_attrs ph on ph.personcenter = p.center and ph.personid = p.id and ph.name = '_eClub_PhoneHome'
 left join person_ext_attrs pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email'
 left join person_ext_attrs pm on pm.personcenter = p.center and pm.personid = p.id and pm.name = '_eClub_PhoneSMS'     
left JOIN 
    PRODUCTS Prod 
    ON 
    Prod.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and Prod.ID = S.SUBSCRIPTIONTYPE_ID
left JOIN 
    SUBSCRIPTIONTYPES ST 
    ON 
    ST.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and ST.ID = S.SUBSCRIPTIONTYPE_ID
left join 
PAYMENT_REQUESTS pr
on
 pr.center = ar.center
 AND pr.id = ar.id    
    
 
 WHERE
-- p.CENTER in (:Center)  and
 P.STATUS in (1,3) /*active + frozen */ and
 P.PERSONTYPE <> 2 /*not staff*/ and
 s.state in (2,4,8) /*and
 ((st.st_type = 2 and pa2.ref is not null) *//*or (st.st_type = 1 and pa2.id is null or pa2.id is null)*//*) */
 --and p.center = 250 --and p.id = 3311
 and longtodate(pa2.last_modified) > :fromdate and longtodate(pa2.last_modified)+1 < :todate
 and (pr.REQ_DELIVERY is not null and pr.req_date-2 > :fromdate and pr.req_date < :todate)
and not exists
(select
ss.subscription_center as center,       
ss.subscription_id as id,
ss.sales_date

from subscription_sales ss

where
sales_date > :fromdate and sales_date < :todate and ss.subscription_center = s.center and ss.subscription_id = s.id )

SELECT DISTINCT
 P.CENTER ||'p'|| P.ID "Member Number",
 P.firstNAME as "Member Name",
 P.LASTNAME as "Member Surname",
 p.sex,
 p.address1 as "Address 1",
 p.address2 as "Address 2",
 p.country as "Country",
 p.zipcode as "Zip",
 ph.txtvalue as "Phone Home",
 pm.txtvalue as "Phone Mobile",
 pem.txtvalue as "Email address",
 case when agr.bank_account_holder is null
 then agr2.bank_account_holder
 else agr.bank_account_holder 
 end as "Account Holder Name",
 case 
 when agr.ref is null
 then agr2.ref
 else agr.ref
 end as "Bacs ref number",
 pr.name as "Subscription Name",
 CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription Status",
 CASE st.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'DD' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS "Subscription Type DD /Cash",
 s.subscription_price as "Current Subscription amount being paid",
 CASE when  agr.name is NULL
 then agr2.name
 else agr.name  
 End as "DD Date",
 s.end_date as "Expiration Date",
 CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status",
 r.relativecenter ||'p'|| r.relativeid as "Family head member"
 
 
 FROM PERSONS P
 
join ACCOUNT_RECEIVABLES ar
on 
ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id

join SUBSCRIPTIONS S 
ON  P.CENTER = S.OWNER_CENTER  
AND P.ID = S.OWNER_ID

JOIN 
    SUBSCRIPTIONTYPES ST 
    ON 
    ST.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and ST.ID = S.SUBSCRIPTIONTYPE_ID
JOIN 
    PRODUCTS PR 
    ON 
    PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and PR.ID = S.SUBSCRIPTIONTYPE_ID   
left join relatives payer on p.center = payer.relativecenter and p.id = payer.relativeid and payer.rtype = 12 and payer.status = 1  

left join ACCOUNT_RECEIVABLES ar2
on 
ar2.CUSTOMERCENTER = payer.center
AND ar2.CUSTOMERID = payer.id

left join
(select distinct
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
pa2.bank_account_holder as bank_account_holder,
pa2.ref ,
pcc.name

from
ACCOUNT_RECEIVABLES ar

join payment_agreements A
 ON
    a.center = ar.center
AND a.id = ar.id


JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id

JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID

JOIN
    CLEARINGHOUSES ch
ON
    a.CLEARINGHOUSE = ch.id
   
JOIN
    CLEARINGHOUSES ch2
ON
    pa2.CLEARINGHOUSE = ch2.id
    
JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    pa2.PAYMENT_CYCLE_CONFIG_ID = pcc.id

where
ar.CUSTOMERCENTER in (:Center) )agr

on
ar.CUSTOMERCENTER = agr.CUSTOMERCENTER
and
ar.CUSTOMERID = agr.CUSTOMERID
and st.st_type = 1

left join
(select distinct
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
pa2.bank_account_holder as bank_account_holder,
pa2.ref ,
pcc.name

from
ACCOUNT_RECEIVABLES ar

join payment_agreements A
 ON
    a.center = ar.center
AND a.id = ar.id


JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id

JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID

JOIN
    CLEARINGHOUSES ch
ON
    a.CLEARINGHOUSE = ch.id
   
JOIN
    CLEARINGHOUSES ch2
ON
    pa2.CLEARINGHOUSE = ch2.id
    
JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    pa2.PAYMENT_CYCLE_CONFIG_ID = pcc.id

where
ar.CUSTOMERCENTER in (:Center) )agr2

on
ar2.CUSTOMERCENTER = agr2.CUSTOMERCENTER
and
ar2.CUSTOMERID = agr2.CUSTOMERID
and st.st_type = 1

 left join relatives r on p.center = r.center and p.id = r.id and r.rtype = 4 and r.status = 1
 left join person_ext_attrs ph on ph.personcenter = p.center and ph.personid = p.id and ph.name = '_eClub_PhoneHome'
 left join person_ext_attrs pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email'
 left join person_ext_attrs pm on pm.personcenter = p.center and pm.personid = p.id and pm.name = '_eClub_PhoneSMS'     

 
 WHERE
 p.CENTER in (:Center)  and
 P.STATUS in (1,3) /*active + frozen */ and
 s.state in (2,4,8)
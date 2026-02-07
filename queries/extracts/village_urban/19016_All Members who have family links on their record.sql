SELECT DISTINCT
c.name as "Club Name",
 P.CENTER ||'p'|| P.ID "Member ID of linked member",
 P.FULLNAME as "Name of linked member",
 CASE st.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'DD' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS "Subscription Type for linked member",
 s.subscription_price as "Subscription Price for linked member",
 CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status of linked member",
extract(year from age(p.BIRTHDATE)) as "Age of linked member",
p.birthdate as "Date of birth of linked member",
t2.checkin_time as "Last Visit Date for linked member",
p.last_active_start_date as "Last Active Start date for Linked Member",
r.relativecenter ||'p'|| r.relativeid as "Member ID of head member",
prel.fullname as "Name of head member",
CASE sthead.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'DD' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS "Subscription Type for linked member",
CASE prel.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status of head member",
prel.last_active_start_date as "Last Active Start date for Head Member",
pace.txtvalue as "Opt In Email for head member",
pacs.txtvalue as "Opt In SMS for head member",
CASE prel.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type of head member",
pem.txtvalue as "Email Address for head member",
pm.txtvalue as "Mobile for head member",
t4.checkin_time as "Last Visit Date for head member"


 FROM PERSONS P
 
join centers c
on c.id = p.center
 
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


 join relatives r on p.center = r.center and p.id = r.id and r.rtype = 4 and r.status = 1
 join persons prel
on
prel.center = r.relativecenter
and prel.id = r.relativeid
 
left join person_ext_attrs pem on pem.personcenter = prel.center and pem.personid = prel.id and pem.name = '_eClub_Email'
left join person_ext_attrs pm on pm.personcenter = prel.center and pm.personid = prel.id and pm.name = '_eClub_PhoneSMS'    
left join person_ext_attrs pace on pace.personcenter = prel.center and pace.personid = prel.id and pace.name = '_eClub_AllowedChannelEmail'
left join person_ext_attrs pacs on pacs.personcenter = prel.center and pacs.personid = prel.id and pacs.name = '_eClub_AllowedChannelSMS'  

 

join SUBSCRIPTIONS shead
ON  Prel.CENTER = Shead.OWNER_CENTER  
AND Prel.ID = Shead.OWNER_ID

JOIN 
    SUBSCRIPTIONTYPES SThead 
    ON 
    SThead.CENTER = Shead.SUBSCRIPTIONTYPE_CENTER 
    and SThead.ID = Shead.SUBSCRIPTIONTYPE_ID
left join
(
select
t1.center,
t1.id,
longtodate(t1.checkin_time) as checkin_time

from
(
select
p.center,
p.id,
rank() over(partition by p.center ||'p'||p.ID ORDER BY chk.checkin_time DESC) as rnk,
chk.checkin_time
from persons p

join relatives r on p.center = r.center and p.id = r.id and r.rtype = 4 and r.status = 1

join checkins chk

on 
chk.person_center = p.center
and
chk.person_id = p.id

WHERE
p.CENTER in (:Center)  and
 P.STATUS in (:person_status)
 )t1
where t1.rnk = 1    
)t2    
on
t2.center = p.center
and t2.id = p.id     

left join
(
select
t3.center,
t3.id,
longtodate(t3.checkin_time) as checkin_time

from
(
select
p.center,
p.id,
rank() over(partition by p.center ||'p'||p.ID ORDER BY chk.checkin_time DESC) as rnk,
chk.checkin_time
from persons p

join relatives r on p.center = r.relativecenter and p.id = r.relativeid and r.rtype = 4
 and r.status = 1

join checkins chk

on 
chk.person_center = p.center
and
chk.person_id = p.id

WHERE
p.CENTER in (:Center)  and
 P.STATUS in (:person_status)
 )t3
where t3.rnk = 1    
)t4    
on
t4.center = prel.center
and t4.id = prel.id     
 
 WHERE
 --p.center = 130  and
--and p.id = 18023 and
 p.CENTER in (:Center)  and
 P.STATUS in (:person_status) /*active + frozen */ 
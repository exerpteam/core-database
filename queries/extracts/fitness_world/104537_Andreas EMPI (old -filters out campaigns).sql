-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                c.id,
                TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')  AS to_date,
                TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') -183 AS monthago
                
        FROM centers c
        WHERE
             -- c.id = 256
               c.id IN (:Scope)
)


SELECT distinct
 p.CENTER ||'p'|| p.id as MEMBERID,
 p.external_id as ExternalID,
 s.center as subscriptioncenter,
 s.id as subscriptionid,
 s.subscription_price,
 pr.NAME as SUBSCRIPTION,
s.START_DATE AS STARTDATE,
s.END_DATE as ENDDATE
--TO_CHAR(longtodate(s.CREATION_TIME), 'DD-MM-YY HH24:MM:SS') AS CREATIONTIME


FROM PERSONS p
join params
on params.id = p.center
JOIN SUBSCRIPTIONS s
ON s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
--and s.start_date < params.monthago
and s.end_date is null 
and s.binding_end_date < params.to_date
JOIN PRODUCTS pr
ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID = s.SUBSCRIPTIONTYPE_ID
join subscriptiontypes st
ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND st.ID = s.SUBSCRIPTIONTYPE_ID
and st.st_type = 1
JOIN 
ACCOUNT_RECEIVABLES ar 
on   
p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID




where
s.state= 2 
and p.persontype = 0
--and p.center = 256
--and p.id = 70619
and p.center IN (:Scope)
and not exists
(select
1
from CASHCOLLECTIONCASES cc
where
 ar.CUSTOMERCENTER = cc.PERSONCENTER
 and ar.CUSTOMERID = cc.PERSONID
 and (cc.amount > 0 ) )
 and not exists 
 (select
 1
 from subscription_price sp
 where 
 s.center = sp.subscription_center
and sp.subscription_id = s.id
and sp.from_date > params.to_date )
and not exists
(select
1
from PRIVILEGE_USAGES pu
JOIN CAMPAIGN_CODES cd
ON cd.ID = pu.CAMPAIGN_CODE_ID
where
pu.PERSON_CENTER = s.OWNER_CENTER
AND pu.PERSON_ID = s.OWNER_ID
and cd.code in ('ÆLDRESAGEN20', 'Studiepris', 'studiepris', 'STUDIEPRIS',  'Studieprisex', 'studieprisex', 'STUDIEPRISEX', 'Studieaarhus', 'studieaarhus', 'STUDIEAARHUS', 'Studieaarhusex', 'studieaarhusex', 'STUDIEAARHUSEX')
)
and not exists
(select
1

from  persons pt

where
p.center = pt.transfers_current_prs_center
and p.id = pt.transfers_current_prs_id
and pt.center in (132,135,249,198,613,245,109,133,187,220,161)
and pt.transfers_current_prs_center not in (132,135,249,198,613,245,109,133,187,220,161)
and pt.status = 4
)
and not exists
(select
1
from PRIVILEGE_USAGES pu2
JOIN CAMPAIGN_CODES cd2
ON cd2.ID = pu2.CAMPAIGN_CODE_ID
join privilege_receiver_groups prg
on cd2.campaign_id = prg.id
where
pu2.PERSON_CENTER = s.OWNER_CENTER
AND pu2.PERSON_ID = s.OWNER_ID
and prg.name like 'Firma%%'

)
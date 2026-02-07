-- This is the version from 2026-02-05
--  
Select
    t1.memberid,
    t1."subID",
    t1.type,
    t1."cancelstop_date",
    t1."Request Remaining step executed",
    t1."remove termination employee",
    t1."remove termination employee name"
from
(

SELECT distinct
    rank() over(partition by s.owner_center ||'p'||s.owner_ID, p.fullname ORDER BY sc.cancel_time DESC) as rnk,
    s.owner_center ||'p'|| s.owner_id as memberid,
    sc.old_subscription_center ||'ss'||sc.old_subscription_id AS "subID",
    sc.type,
    TO_CHAR(longtodateTZ(sc.cancel_time, 'Europe/Copenhagen'),'YYYY-MM-DD ') AS "cancelstop_date",
    TO_CHAR(longtodateTZ(sc.change_time, 'Europe/Copenhagen'),'YYYY-MM-DD ') AS "Request Remaining step executed",
    je.creatorcenter ||'emp'|| je.creatorid  as "remove termination employee",
    p.fullname as "remove termination employee name"
  
FROM
    subscription_change sc
JOIN
    subscriptions s
ON
    sc.old_subscription_center = s.center
AND sc.old_subscription_id = s.id

JOIN
    ACCOUNT_RECEIVABLES ar
ON
    s.owner_center = ar.customercenter
AND s.owner_id = ar.customerid
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
join journalentries je
on
je.person_center = s.owner_center
and
je.person_id = s.owner_id
and
je.jetype = 19 
and
je.creation_time > sc.cancel_time

left join employees emp
on
emp.center = je.creatorcenter
and
emp.id = je.creatorid
and
je.creation_time > sc.cancel_time

left join persons p
on
emp.personcenter = p.center
and
emp.personid = p.id



WHERE
    sc.type = 'END_DATE'
AND art.STATUS IN ('OPEN',
                   'NEW')
AND s.state = 2 -->ACTIVE<--
AND s.end_date IS NULL
AND sc.cancel_time IS NOT NULL
AND art.due_date <= add_months(CURRENT_DATE, -3) 
)t1
where rnk =1
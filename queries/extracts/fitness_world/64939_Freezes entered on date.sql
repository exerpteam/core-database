-- This is the version from 2026-02-05
-- EC-889
Select
s.owner_center ||'p'|| s.owner_id as memberid,
sfp.START_DATE as freezestartdate,
sfp.END_DATE as freezeenddate,
to_char(longtodate(sfp.entry_time), 'dd-MM-YYYY HH:Mi') as entrytime,
sfp.EMPLOYEE_CENTER ||'emp'|| sfp.EMPLOYEE_ID AS EMPLOYEEID,
p.FULLNAME AS EMPLOYEENAME


From
SUBSCRIPTION_FREEZE_PERIOD sfp

join
SUBSCRIPTIONS s
on
s.center = sfp.SUBSCRIPTION_CENTER
and
s.id = SUBSCRIPTION_ID
join EMPLOYEES emp on emp.CENTER = sfp.EMPLOYEE_CENTER and emp.ID = sfp.EMPLOYEE_ID 
join PERSONS p on p.CENTER = emp.PERSONCENTER and p.ID = emp.PERSONID 

where 

longtodate(sfp.ENTRY_TIME) between (:entry_time_of_freeze) and (:entry_time_of_freeze)+1
and sfp.cancel_time is NULL
and sfp.end_date >= sysdate
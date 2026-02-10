-- The extract is extracted from Exerp on 2026-02-08
--  
Select
count(*) AS freeze_count,
s.owner_center ||'p'|| s.owner_id as memberid,
--sfp.START_DATE as freezestartdate,
--sfp.END_DATE as freezeenddate
TO_CHAR(longtodate(sfp.entry_time), 'DD-MM-YYYY') as "DATE"
From
SUBSCRIPTION_FREEZE_PERIOD sfp

join
SUBSCRIPTIONS s
on
s.center = sfp.SUBSCRIPTION_CENTER
and
s.id = sfp.SUBSCRIPTION_ID

where 

--sfp.ENTRY_TIME >= (FromDate) 
--and sfp.ENTRY_TIME < (ToDate)
sfp.cancel_time is NULL
AND sfp.end_date > sysdate
AND sfp.subscription_center in (:scope)

GROUP BY
s.owner_center,
s.owner_id
--sfp.START_DATE,
--sfp.END_DATE
--TO_CHAR(longtodate(sfp.entry_time), 'DD-MM-YYYY')

ORDER BY 1 DESC
-- This is the version from 2026-02-05
--  
select 
fr.id as FreezeId, 
sub.CENTER || 'ss' || sub.id as SubscriptionId,  p.center || 'p' || p.id MemberNo, fr.START_DATE, fr.END_DATE
from FW.SUBSCRIPTION_FREEZE_PERIOD fr
join FW.SUBSCRIPTIONS sub on fr.SUBSCRIPTION_CENTER = sub.CENTER and fr.SUBSCRIPTION_ID = sub.id
join PERSONS p on sub.OWNER_CENTER = p.center and sub.OWNER_ID = p.id
where fr.STATE = 'ACTIVE' 
and p.center in (:scope) 
and p.status in (0,1,2,3,4,6,9) 
 and p.sex != 'C' and p.center not in (100)
--and sub.STATE in (2,4,8)
--and fr.START_DATE <= to_date(to_char(exerpsysdate(), 'YYYY-MM-DD'), 'YYYY-MM-DD') 
--and fr.END_DATE >= to_date(to_char(exerpsysdate(), 'YYYY-MM-DD'), 'YYYY-MM-DD')
order by 3,2,4
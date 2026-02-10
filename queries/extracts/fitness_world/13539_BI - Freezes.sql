-- The extract is extracted from Exerp on 2026-02-08
--  
select sub.CENTER || 'ss' || sub.id as SubscriptionId, fr.START_DATE, fr.END_DATE
from FW.SUBSCRIPTION_FREEZE_PERIOD fr
join FW.SUBSCRIPTIONS sub on fr.SUBSCRIPTION_CENTER = sub.CENTER and fr.SUBSCRIPTION_ID = sub.id
where sub.OWNER_CENTER in (:scope)
and fr.STATE = 'ACTIVE'
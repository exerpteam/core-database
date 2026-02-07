-- This is the version from 2026-02-05
--  
select 
p.center || 'p' || p.id MemberNo,
pd.NAME as MembershipType,
sub.START_DATE as StartDate,
sub.END_DATE as EndDate,
case when sub.STATE in (2,4,8) then 'Y' else 'N' end as Active

from persons p 
join SUBSCRIPTIONS sub on p.center = sub.OWNER_CENTER and p.id = sub.OWNER_ID
join FW.SUBSCRIPTIONTYPES st on st.center = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join FW.PRODUCTS pd on pd.center = st.center and pd.id = st.id

where p.center in (:scope) and p.status in (1,3) and p.sex != 'C' and p.PERSONTYPE != 2 and p.center not in (100)
order by 1, 3
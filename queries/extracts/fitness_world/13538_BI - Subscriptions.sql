-- This is the version from 2026-02-05
--  
select 
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID as MemberId,
    sub.center || 'ss' || sub.id as SubscriptionId,
    sub.START_DATE as StartDate,
    sub.END_DATE as EndDate,
    pd.name as MembershipType,
    sub.SUBSCRIPTION_PRICE as Price,
--    emp.center || 'emp' || emp.id as SOURCE,
    case when emp.center = 114 and emp.id = 813 then 'WEB' when emp.center = 100 and emp.id = 1 then 'IMPORT' else 'STAFF' end as Source,
--    emp_per.FULLNAME as SOURCE,
    decode(st.ST_TYPE, 0, 'KONTANT', 1, 'PBS') as PaymentType,
    case when emp.center = 100 and emp.id = 1 then 'Y' else 'N' end as Imported
from FW.SUBSCRIPTIONS sub
join FW.SUBSCRIPTIONTYPES st on st.center = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join FW.PRODUCTS pd on pd.center = st.center and pd.id = st.id
left join FW.EMPLOYEES emp on emp.CENTER = sub.CREATOR_CENTER and emp.id = sub.CREATOR_ID
--left join FW.PERSONS emp_per on emp_per.center = emp.PERSONCENTER and emp_per.id = emp.PERSONID
where sub.OWNER_CENTER in (:scope)
and (sub.END_DATE is null or sub.end_date >= sub.start_date)
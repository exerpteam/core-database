-- The extract is extracted from Exerp on 2026-02-08
--  
select 
p.center || 'p' || p.id MemberNo,
sub.center || 'ss' || sub.id SubscriptionId,
pd.NAME as MembershipType,
sub.START_DATE as StartDate,
sub.END_DATE as EndDate,
case when (sub.STATE in (2,4,8) and (sub.end_date is null or sub.end_date >= to_date(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD'), 'YYYY-MM-DD'))) then 'Y' else 'N' end as Active,
sub.SUBSCRIPTION_PRICE as Price,
decode(st.ST_TYPE, 0, 'KONTANT', 1, 'PBS') as PaymentType,
pg.NAME as ProductGroup,
case when (ces.LASTUPDATED is not null and ces.LASTUPDATED >= longtodate(sub.CREATION_TIME)) then 'YES' else 'NO' end as Imported
,ivl.TOTAL_AMOUNT as JoiningFee
--,decode(sub.SUB_STATE, 3, 'YES', 4, 'YES', 'NO') as UP_DOWNGRADE
from persons p 
join SUBSCRIPTIONS sub on p.center = sub.OWNER_CENTER and p.id = sub.OWNER_ID
join SUBSCRIPTIONTYPES st on st.center = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join PRODUCTS pd on pd.center = st.center and pd.id = st.id
join PRODUCT_GROUP pg on pd.PRIMARY_PRODUCT_GROUP_ID = pg.ID
left join INVOICELINES ivl on ivl.CENTER = sub.INVOICELINE_CENTER and ivl.id = sub.INVOICELINE_ID and ivl.subid = sub.INVOICELINE_SUBID
left join FW.CONVERTER_ENTITY_STATE ces on ces.NEWENTITYCENTER = p.center and ces.NEWENTITYID = p.id and ces.WRITERNAME = 'ClubLeadSubscriptionWriter'
where p.status in (0,1,2,3,4,6,9)  and p.sex != 'C' and p.center not in (100)
and p.center in (:scope) 
order by 1, 3
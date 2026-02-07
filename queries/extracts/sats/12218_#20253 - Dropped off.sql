select countrya.NAME as Country, regiona.NAME as Region, c.name as CenterName, c.id as CenterId, decode(latest_sub.st_type, 0, 'EFT', 1, 'CASH') as CURRENT_MEMBERSHIP_TYPE, count(*) as MEMBER_COUNT, round(avg(p.MEMBERDAYS), 0) as UNBROKEN_MEMBERSHIP_DAYS
from PERSONS p
join centers c on p.center = c.id
join AREA_CENTERS regionac on regionac.CENTER = c.id
join AREAS regiona on regiona.ID = regionac.AREA
join AREAS countrya on countrya.ID = regiona.PARENT and countrya.PARENT = 1
join (
select sub.OWNER_CENTER, sub.OWNER_ID, 
sub.START_DATE, st.ST_TYPE, pd.name,
ROW_NUMBER( ) OVER (PARTITION BY
sub.owner_center, sub.owner_id ORDER BY sub.start_date desc) ROWNR
from SUBSCRIPTIONS sub 
join SUBSCRIPTIONTYPES st on st.center  = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join PRODUCTS pd on pd.center  = sub.SUBSCRIPTIONTYPE_CENTER and pd.id = sub.SUBSCRIPTIONTYPE_ID
join PRODUCT_GROUP pg on pg.ID = pd.PRIMARY_PRODUCT_GROUP_ID
where sub.sub_state not in (7,8) and pg.NAME in (
'Cash Memberships',
'EFT Memberships',
'Limited Memberships',
'Flex Memberships'
)
and sub.end_date is not null 
and sub.end_date >= :from_date and sub.end_date < eclub2.longtodate(:to_date) -- sub end date between from and to (exclusive)
) latest_sub on p.center = latest_sub.OWNER_CENTER and p.id = latest_sub.OWNER_ID and latest_sub.ROWNR = 1
join STATE_CHANGE_LOG scl on scl.CENTER = p.center and scl.id = p.id and scl.ENTRY_TYPE = 1 and scl.STATEID in (2) and scl.BOOK_START_TIME <= :to_date and (scl.BOOK_END_TIME is null 
--or scl.BOOK_END_TIME > :to_date
)
where
p.center in (:scope)
--and p.id = 88817
--and p.id = 3889
and p.PERSONTYPE != 2
and p.status in (0,2)
and p.LAST_ACTIVE_END_DATE < eclub2.longtodate(eclub2.datetolong('2011-02-01 00:00'))
--and (p.LAST_ACTIVE_START_DATE is not null or p.MEMBERDAYS is not null)-- FIX THIS

group by countrya.NAME, regiona.NAME, c.id, c.name, latest_sub.st_type
order by countrya.NAME, regiona.NAME, c.id, latest_sub.st_type
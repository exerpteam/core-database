select countrya.NAME as Country, regiona.NAME as Region, c.name as CenterName, c.id as CenterId, decode(latest_sub.st_type, 0, 'EFT', 1, 'CASH') as CURRENT_MEMBERSHIP_TYPE, count(*) as MEMBER_COUNT, round(avg(trunc((exerpsysdate() - p.LAST_ACTIVE_START_DATE)  +  NVL(p.MEMBERDAYS,0) ) + 1), 0) as UNBROKEN_MEMBERSHIP_DAYS
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
where sub.state in (2,4) and pg.NAME in (
'Cash Memberships',
'EFT Memberships',
'Limited Memberships',
'Flex Memberships'
)
) latest_sub on p.center = latest_sub.OWNER_CENTER and p.id = latest_sub.OWNER_ID and latest_sub.ROWNR = 1
where

p.center in (:scope)
and p.PERSONTYPE != 2
and p.STATUS in (1,3)
and p.LAST_ACTIVE_START_DATE is not null -- FIX THIS

group by countrya.NAME, regiona.NAME, c.id, c.name, latest_sub.st_type
order by countrya.NAME, regiona.NAME, c.id, latest_sub.st_type
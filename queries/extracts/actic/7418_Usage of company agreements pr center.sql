-- The extract is extracted from Exerp on 2026-02-08
-- agreements not used isn't, and can't be, listed
select
    count(distinct(p.center||'p'||p.id)) as customer_count,
    ca.name as companyagreement_name,
    com.lastname as company_name,
    com.center||'p'||com.id as company_id,
    p.center as person_center,
	CASE ca.state  WHEN 1 THEN  'AKTIV'  WHEN 2 THEN 'STOPPA NY' END as state,
	CASE ca.blocked  WHEN 1 THEN  'JA'  WHEN 0 THEN  'NEJ' END as blocked,
	ca.STOP_NEW_DATE
from
     COMPANYAGREEMENTS ca
JOIN PERSONS com
    ON
        com.center = ca.center
    AND com.id = ca.id
    AND com.sex = 'C'
left JOIN PRIVILEGE_GRANTS pg
    ON
        pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
join relatives rel
    on
        rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
join persons p
    on
        rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    and rel.status in (1) -- active
join subscriptions s
    on
        rel.CENTER = s.owner_center
    AND rel.ID = s.owner_id
join subscriptiontypes st  
    on  s.subscriptiontype_center = st.center 
    and s.subscriptiontype_id = st.id
WHERE
    ca.state in (1,2,3)  -- active, stop new, old
    and p.status in (1,3) -- active or temp.inactive
	and p.center in (:scope)
group by
    ca.name,
    com.lastname,
    com.center,
    com.id,
    p.center,
	ca.state,
	ca.blocked,
	ca.STOP_NEW_DATE
ORDER BY
    p.center,
    ca.NAME,
    com.lastname

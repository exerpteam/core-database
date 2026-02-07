select
    com.lastname as company_name,     
ca.name as companyagreement_name,
CASE ca.state
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Stop New'
        WHEN 3
        THEN 'Old'
        END AS "agreement_state",
count(distinct(p.center||'p'||p.id)) as customer_count,
  com.center||'p'||com.id as company_id,
    p.center as Comany_center
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
    and p.status in (1,2,3) -- active or temp.inactive
	and p.center in (:scope)
group by
    ca.name,
    com.lastname,
    com.center,
    com.id,
    p.center,
	ca.state
ORDER BY
    p.center,
    ca.NAME,
    com.lastname
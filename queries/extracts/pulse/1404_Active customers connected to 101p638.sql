SELECT 
    c.center||'p'||c.id             as CompanyId, 
    c.lastname                      as company, 
    p.center||'p'||p.id             as Customer, 
    p.FULLNAME                      as CustomerName,
    pro.name                        as productname,
    s.start_date                    as sub_start_date
from
    pulse.persons p
JOIN 
    pulse.RELATIVES rel 
    ON 
    rel.RELATIVECENTER    = p.CENTER 
    AND rel.RELATIVEID    = p.ID 
    AND rel.RTYPE         = 2 
JOIN 
    pulse.PERSONS c 
    ON 
    rel.CENTER    = c.CENTER 
    AND rel.ID    = c.ID 
join
    pulse.subscriptions s
    on
    p.center = s.owner_center
    and p.id = s.owner_id
join
    pulse.subscriptiontypes st
    on
    s.subscriptiontype_center = st.center
    and s.subscriptiontype_id = st.id
join
    pulse.products pro
    on
    st.center = pro.center
    and st.id = pro.id
WHERE 
    c.CENTER = 101
	and c.id = 638
    and p.center in (:scope)
	and p.status = 1 -- active
group by
	c.center,c.id, 
    c.lastname, 
    p.center,p.id, 
    p.FULLNAME,
    pro.name,
    s.start_date  
ORDER BY 
    c.center, 
    c.id,
    p.fullname
Select
p.center||'p'||p.id as companyId,
     p.LASTNAME as companyname,
     ca.NAME as agreementname,
CASE ca.state WHEN 0 THEN 'Under target' WHEN 1 THEN 'Active' WHEN 2 THEN 'Stop new' WHEN 3 THEN 'Old' WHEN 4 THEN 'Awaiting activation' WHEN 5 THEN 'Blocked' WHEN 6 THEN 'Deleted' END AS company_agreement_state,
ca.roleid,
r.rolename,
r.blocked
from persons p 
join companyagreements ca on p.center = ca.center AND p.id = ca.id
join roles r on ca.roleid = r.id
WHERE p.sex = 'C'
AND p.center in (:scope)
AND r.blocked = true
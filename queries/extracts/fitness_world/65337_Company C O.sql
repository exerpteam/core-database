-- The extract is extracted from Exerp on 2026-02-08
--  
select 
p.center ||'p'|| p.id,
p.co_name
from persons p
where
(P.CENTER,P.ID) in (:companyID)
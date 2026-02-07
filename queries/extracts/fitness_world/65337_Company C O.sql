-- This is the version from 2026-02-05
--  
select 
p.center ||'p'|| p.id,
p.co_name
from persons p
where
(P.CENTER,P.ID) in (:companyID)
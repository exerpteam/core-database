-- This is the version from 2026-02-05
--  
SELECT 
p.CENTER ||'p'|| p.ID as "Member Number",
p.STATUS AS "Person_status"

FROM PERSONS p

where (p.CENTER) in ($$scope$$)

-- active members(p.STATUS) in (1,3)
--(p.STATUS) in (2)
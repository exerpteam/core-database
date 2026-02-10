-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
p.CENTER ||'p'|| p.ID as "Member Number",
p.STATUS AS "Person_status"
p.personkey as 'Password'

FROM PERSONS p

where (p.CENTER) in ($$scope$$)

-- active members(p.STATUS) in (1,3)
--(p.STATUS) in (2)
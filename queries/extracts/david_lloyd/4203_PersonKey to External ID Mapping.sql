-- This is the version from 2026-02-05
--  
SELECT 
    p.center||'p'||p.id AS "PersonKey" ,
    cp.external_id as "ExternalID"
FROM 
    persons p 
JOIN 
    persons cp 
ON 
    cp.center = p.transfers_current_prs_center 
AND cp.id = p.transfers_current_prs_id
where p.center in ($$scope$$)
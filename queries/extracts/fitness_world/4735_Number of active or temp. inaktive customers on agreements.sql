-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ca.center||'p'||ca.id as Company_ID,
    c.lastname            as Company_name,
    ca.name               as agreement_name,
    count(distinct p.center||'p'||p.id) as Number_of_customers
FROM
     COMPANYAGREEMENTS ca
JOIN PERSONS c
ON
     ca.CENTER = c.CENTER
AND  ca.ID = c.ID
JOIN RELATIVES rel
ON
     rel.RELATIVECENTER = ca.CENTER
AND  rel.RELATIVEID = ca.ID
AND  rel.RELATIVESUBID = ca.SUBID
AND  rel.RTYPE = 3 /* persons under agreement*/
JOIN PERSONS p
ON
     rel.CENTER = p.CENTER
AND  rel.ID = p.ID
AND  rel.RTYPE = 3
WHERE
     p.STATUS in (1,3)
and  rel.status < 3 /*lead, active, inactive.. not '3' = blocked*/
group by
     ca.center||'p'||ca.id, 
     c.lastname,         
     ca.name              
order by
     ca.center||'p'||ca.id
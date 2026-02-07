SELECT 
    c.id AS "Club ID",
    c.name AS "Club Name",
    c.state AS "State"
FROM 
    fernwood.centers c
WHERE 
    c.id IN (:Scope)
ORDER BY 
    c.state, c.name;
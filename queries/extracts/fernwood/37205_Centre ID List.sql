SELECT 
    c.id AS "Club ID",
    c.name AS "Club Name", 
    c.shortname AS "Club Short Name",
    c.state AS "State"
FROM 
    centers c
WHERE 
    c.id IN (:Scope)
ORDER BY 
    c.state, c.name;
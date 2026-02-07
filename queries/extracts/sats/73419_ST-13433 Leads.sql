SELECT p.center||'p'||p.id as PersonID,
p.firstname,
p.lastname 
FROM SATS.PERSONS p
WHERE p.FIRSTNAME = 'Røa Bad Gjest' 
ORDER BY p.lastname
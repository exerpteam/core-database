SELECT p.center || 'p' || p.id AS "PersonID",p.*

FROM Persons p

WHERE p.persontype = 3
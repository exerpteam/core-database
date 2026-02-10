-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center || 'p' || p.id as "Member ID",
pea.TXTVALUE AS "Group Class Contest"


FROM
Persons p
JOIN
   Person_Ext_Attrs pea
ON
 p.center = pea.personcenter
AND
p.id = pea.personid
WHERE
pea.name = 'KursGewinnspiel'
and
pea.TXTVALUE is not NULL
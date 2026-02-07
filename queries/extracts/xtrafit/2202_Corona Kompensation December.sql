SELECT
p.center || 'p' || p.id as "Membership number",
pea.TXTVALUE AS "Corona Kompensation December"


FROM
Persons p
JOIN
   Person_Ext_Attrs pea
ON
 p.center = pea.personcenter
AND
p.id = pea.personid
WHERE
pea.name = 'A2'
and
pea.TXTVALUE is not NULL
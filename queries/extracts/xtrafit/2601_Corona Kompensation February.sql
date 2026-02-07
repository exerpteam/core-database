SELECT
p.center || 'p' || p.id as "Membership number",
pea.TXTVALUE AS "Corona Kompensation February"


FROM
Persons p
JOIN
   Person_Ext_Attrs pea
ON
 p.center = pea.personcenter
AND
p.id = pea.personid
WHERE
pea.name = 'A4'
and
pea.TXTVALUE is not NULL
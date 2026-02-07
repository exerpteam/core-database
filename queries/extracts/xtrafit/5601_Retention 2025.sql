SELECT
p.center || 'p' || p.id as "Membership number",
pea.TXTVALUE AS "Retention 2025"


FROM
Persons p
JOIN
   Person_Ext_Attrs pea
ON
 p.center = pea.personcenter
AND
p.id = pea.personid
WHERE
pea.name = 'WellhubID'
and
pea.TXTVALUE is not NULL
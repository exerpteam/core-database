SELECT
p.center || 'p' || p.id as "Membership number",
pea.TXTVALUE AS "WellhubID"


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
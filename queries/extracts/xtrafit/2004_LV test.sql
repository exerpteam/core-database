-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
p.id || 'p' || p.center as membership_number,
A1.NAME as November,
A1.TXTVALUE as November_value,
A2.NAME as December,
A2.TXTVALUE as December_value,
A3.NAME as January,
A3.TXTVALUE as January_value


FROM
Persons p

left JOIN
   Person_Ext_Attrs A1
ON
 p.center = A1.personcenter
AND
p.id = A1.personid
and
A1.name = 'A1'

Join
   Person_Ext_Attrs A2
ON
 p.center = A2.personcenter
AND
p.id = A2.personid
and
A2.name = 'A2'
Join
   Person_Ext_Attrs A3
ON
 p.center = A3.personcenter
AND
p.id = A3.personid
and
A3.name = 'A3'

Where
p.center in :scope
  
-- The extract is extracted from Exerp on 2026-02-08
--  
select
p.external_id,
p.fullname,
TO_CHAR(longtodateC(pea.last_edit_time,pea.personcenter), 'dd-mm-yyyy') AS "Date",
pea.txtvalue as "Error_code"

from
persons p
join
person_ext_attrs pea
on
p.id = pea.personid
and
p.center = pea.personcenter
and
pea.name = 'Error'
join
person_ext_attrs peas
on
p.id = peas.personid
and
p.center = peas.personcenter
and
peas.name = 'StatusOK'
and
peas.txtvalue = 'false'

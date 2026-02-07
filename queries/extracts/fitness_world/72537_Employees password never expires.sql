-- This is the version from 2026-02-05
--  
select distinct
e.PERSONCENTER ||'p'|| e.PERSONID PERSONID,
e.BLOCKED,
e.status,
p.fullname
--e.CENTER ||'emp'|| e.ID STAFFID
from employees e
left join persons p
on e.PERSONCENTER = p.center
AND e.PERSONID = p.id
Where
e.PASSWD_NEVER_EXPIRES = 1
--AND e.BLOCKED in (Blockstatus)
ORDER BY
PERSONID
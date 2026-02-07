-- This is the version from 2026-02-05
--  
select
c.ID as Center_ID,
c.NAME as Center_name,
a.ID as Area_ID,
a.NAME as Area_Name,
a.PARENT as area_parent
from centers c
left join area_centers ac on
c.ID = ac.center
left join areas a
on ac.area = a.ID
Where
a.ROOT_AREA = 544 -- Full Estate PG Dec 2024
AND a.PARENT is not null
--AND a.ID not in (196, 197, 198,332,333,334,339,340,341)
and a.name != 'Lukkede centre'
AND a.name != 'Admin'
AND a.name != 'Polen'
order by
a.ID

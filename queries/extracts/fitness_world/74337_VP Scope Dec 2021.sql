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
a.ROOT_AREA = 168
AND a.PARENT is not null
AND a.ID not in (169, 176, 175)
order by
a.ID

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
left join areas a2
on
a.root_area = a2.id
Where
a2.name = :name
--a.ROOT_AREA = 146
AND a.PARENT is not null
AND a.ID not in (147, 148, 151, 155)
order by
a.ID
-- The extract is extracted from Exerp on 2026-02-08
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
a.ROOT_AREA = 256
AND a.PARENT is not null
AND a.ID not in (209,210,211,228,229,230,240,241,242,266,267,268)
order by
a.ID

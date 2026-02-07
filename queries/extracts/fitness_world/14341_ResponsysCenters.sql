-- This is the version from 2026-02-05
--  
select c.id, c.NAME, c.ADDRESS1, c.ADDRESS2, c.ZIPCODE, c.CITY from centers c
left join FW.AREA_CENTERS ac on ac.CENTER = c.id and ac.AREA = 3
where ac.center is null
order by 1
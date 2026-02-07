-- This is the version from 2026-02-05
--  
select
cen.ID,
cen.name,
cen.shortname,
cen.address1,
cen.address2,
cen.zipcode,
cen.city,
cen.latitude,
cen.longitude,
cea.TXT_VALUE AS Region

from
     centers cen

LEFT JOIN CENTER_EXT_ATTRS cea
ON cen.ID = cea.CENTER_ID
AND cea.NAME = 'Region'
Where cen.ID in (:scope)
order by cen.shortname
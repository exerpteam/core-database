-- The extract is extracted from Exerp on 2026-02-08
--  
/*SELECT 
s.*,
pr.NAME,
spp.*
FROM SUBSCRIPTIONS s
JOIN
PRODUCTS pr
ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID = s.SUBSCRIPTIONTYPE_ID
JOIN MASTERPRODUCTREGISTER mpr
ON mpr.GLOBALID = pr.GLOBALID
JOIN SUBSCRIPTIONTYPES st
ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN SUBSCRIPTIONPERIODPARTS spp
ON spp.CENTER = s.CENTER
AND spp.ID = s.ID
WHERE s.center = 100
AND s.id in (76506, 72309)*/

select to_number(to_char(DATE '2019-01-01', 'J')),
to_number(to_char(sysdate, 'J')),
to_number(to_char(exerpsysdate(), 'J'))
from dual
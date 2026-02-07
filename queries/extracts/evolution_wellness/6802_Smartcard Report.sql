SELECT 
DISTINCT P.CENTER ||'p'|| P.ID AS Person_ID, 
p.external_id,
gc.IDENTITY AS RFCARD,
(TO_CHAR(longtodateC(gc.start_time,p.center),'YYYY-MM-DD')) AS "RFCard_Start_Time" ,
mc.IDENTITY AS BARCODE, 
(TO_CHAR(longtodateC(mc.start_time,p.center),'YYYY-MM-DD')) AS "Barcode_Start_Time" ,
CASE
        WHEN mc.IDENTITY LIKE '81%' THEN 'Red Gantner'
        WHEN mc.IDENTITY LIKE '82%' THEN 'Gold'
	WHEN mc.IDENTITY LIKE '83%' THEN 'Off-peak'             
        ELSE 'Other'
   	END AS "Membership Type" ,
P.FULLNAME AS FULLNAME,
CE.NAME AS CENTER,
prod.name,
s.start_date
from 
PERSONS AS P 
LEFT join SUBSCRIPTIONS AS S ON (P.CENTER = S.OWNER_CENTER AND P.ID = S.OWNER_ID) 
LEFT join CENTERS AS CE ON P.CENTER = CE.ID 
LEFT join ENTITYIDENTIFIERS AS mc ON (P.CENTER = mc.REF_CENTER AND P.ID = mc.REF_ID AND mc.ENTITYSTATUS = 1)
LEFT join ENTITYIDENTIFIERS AS gc ON (P.CENTER = gc.REF_CENTER AND P.ID = gc.REF_ID AND gc.IDMETHOD = 4 AND gc.ENTITYSTATUS = 1)
 JOIN evolutionwellness.subscriptiontypes st ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id
 JOIN evolutionwellness.products prod ON prod.center = st.center AND prod.id = st.id
where 
P.CENTER IN (123, 109, 112, 121, 105, 124, 118, 104, 108, 115, 119, 116, 111, 103, 110, 117, 100)
and (TO_CHAR(longtodateC(mc.start_time,p.center),'YYYY-MM-DD')) Between '2025-12-01' and '2025-12-31'
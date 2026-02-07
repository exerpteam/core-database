-- This is the version from 2026-02-05
--  
SELECT 
ca.center as companycenter, 
ca.id as companyid, 
c.lastname as company,
c.address1 as addresse1,
c.zipcode as zip, 
zipcodes.city, 
count (p.center||'p'|| p.id) as antal_mere_end_eller_lig_30
FROM 
fw.COMPANYAGREEMENTS ca 
JOIN fw.PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID
JOIN  fw.RELATIVES rel ON rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID = ca.ID AND rel.RELATIVESUBID = ca.SUBID  AND rel.RTYPE = 3 
JOIN fw.PERSONS p ON rel.CENTER = p.CENTER AND rel.ID = p.ID  AND rel.RTYPE = 3
LEFT JOIN fw.subscriptions s  ON s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID = rel.ID AND s.STATE IN (2,4 )
LEFT JOIN fw.subscriptiontypes st ON  s.subscriptiontype_center = st.center and s.subscriptiontype_id = st.id
LEFT JOIN fw.products prod ON  st.center = prod.center and st.id = prod.id
left join fw.zipcodes on c.country=zipcodes.country and c.zipcode=zipcodes.zipcode 
WHERE
p.STATUS in (1,3)
and rel.STATUS = 1
group by
ca.center, 
ca.id, 
c.lastname, 
c.address1,
c.zipcode, 
zipcodes.city 
having count (p.center||'p'|| p.id) >=30
select c.center ||'cc'||c.id||'cc'||c.subid as CLIPID, c.owner_center||'p'||c.owner_id as memberid, p.external_id as MMS_ID, p.fullname from clipcards c
join persons p on p.center = c.owner_center and p.id = c.owner_id  
where 
c.center ||'cc'||c.id||'cc'||c.subid in ($$clipid$$)
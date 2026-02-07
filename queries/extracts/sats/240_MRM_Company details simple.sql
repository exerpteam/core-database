SELECT 
ca.center as companycenter, 
ca.id as companyid, 
ca.subid as agreementid, 
c.lastname as company,
c.zipcode as ZipCode, 
ca.name as agreement, 
mc.lastname as mothercompany, 
mc.center as mccenter, 
mc.id as mcid, 
key.firstname || ' ' || key.lastname as employeeName, 

( SELECT COUNT(*) FROM /*company agreement relation*/ ECLUB2.RELATIVES rel , /* persons under agreement*/ ECLUB2.PERSONS p , ECLUB2.subscriptions s WHERE rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID = ca.ID AND rel.RELATIVESUBID = ca.SUBID AND rel.RTYPE = 3 AND rel.CENTER = p.CENTER AND rel.ID = p.ID AND rel.RTYPE = 3 AND s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID = rel.ID AND 
s.start_date < @@date::fromDate::From Date@@
 AND 
( s.end_date > @@date::fromDate::From Date@@
  or s.end_date IS NULL ) ) 
as MembersBeginning 

FROM

ECLUB2.COMPANYAGREEMENTS ca /* company */ JOIN ECLUB2.PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID /* mother company */ LEFT JOIN ECLUB2.RELATIVES relc ON relc.RELATIVECENTER = c.CENTER AND relc.RELATIVEID = c.ID AND relc.RTYPE = 6 LEFT JOIN ECLUB2.PERSONS mc ON relc.CENTER = mc.CENTER AND relc.ID = mc.ID AND relc.RTYPE = 6 /* key account manager */ LEFT JOIN ECLUB2.RELATIVES relkey ON relkey.CENTER = c.CENTER AND relkey.ID = c.ID AND relkey.RTYPE = 10 LEFT JOIN ECLUB2.PERSONS key ON relkey.RELATIVECENTER = key.CENTER AND relkey.RELATIVEID = key.ID AND relkey.RTYPE = 10 ORDER BY ca.center, ca.id, ca.subid

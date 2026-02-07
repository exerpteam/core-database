select p.center || 'p' || p.id as PersonId, p.FIRSTNAME, p.lastname, ei.IDENTITY, 
decode(p.status, 1, 'Active', 3, 'TempInactive', 'Inactive')
from HP.PERSONS p
join HP.ENTITYIDENTIFIERS ei on ei.REF_CENTER = p.center and ei.REF_ID = p.id and ei.REF_TYPE = 1
where p.status in (0,1,2,3,6,9) and ei.ENTITYSTATUS = 1 and ei.IDMETHOD = 2
and p.center in (5)
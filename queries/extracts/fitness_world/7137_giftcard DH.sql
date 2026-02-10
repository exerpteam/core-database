-- The extract is extracted from Exerp on 2026-02-08
--  
select 
g.CENTER,
g.ID,
e.identity,
decode(g.STATE,0,'issued',3,'used', 2,'expired',1,'cancelled',4,'Partially Used'),
g.AMOUNT,
g.AMOUNT_REMAINING,
g.INVOICELINE_CENTER,
g.INVOICELINE_ID,
g.INVOICELINE_SUBID,
g.EXPIRATIONDATE,
LongToDate(g.USE_TIME)
 from 
GIFT_CARDS g
join entityidentifiers e on e.REF_CENTER = g.center and e.REF_ID = g.id 
where 
e.IDMETHOD = 1 AND
e.REF_TYPE = 5 and
g.center = :centernr
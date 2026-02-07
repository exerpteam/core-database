-- This is the version from 2026-02-05
-- Made redundant with new view.
Administration -> Economics -> Finance -> Giftcard
select 
g.CENTER||'gc'||g.ID as giftcardID,
e.identity,
decode(g.STATE,0,'issued',3,'used', 2,'expired',1,'cancelled',4,'Partially Used') as STATUS,
g.AMOUNT,
g.AMOUNT_REMAINING,
g.INVOICELINE_CENTER,
g.INVOICELINE_ID,
g.INVOICELINE_SUBID,
g.EXPIRATIONDATE,
LongToDate(g.USE_TIME) as USE_TIME
 from 
GIFT_CARDS g
join entityidentifiers e on e.REF_CENTER = g.center and e.REF_ID = g.id 
where 
e.IDMETHOD = 1 AND
e.REF_TYPE = 5 and
e.ref_center in (:center) 
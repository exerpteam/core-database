 SELECT
     c.owner_center||'p'||c.owner_id as clipcard_owner,
     c.clips_left,
     pro.name,
     CASE c.finished when false then 'Active' when true then 'Finished' end as clipcard_state
 FROM
      pulse.CLIPCARDS C
 JOIN pulse.PERSONS P
     ON
     C.OWNER_CENTER=P.CENTER
     AND C.OWNER_ID=P.ID
 JOIN pulse.INVOICELINES IL
     ON
     C.INVOICELINE_CENTER = il.center
     and C.INVOICELINE_ID = il.id
     and C.INVOICELINE_SUBID = il.subid
 JOIN pulse.PRODUCTS Pro
     ON
     IL.PRODUCTCENTER=Pro.CENTER
     AND IL.PRODUCTID=Pro.ID
 WHERE
     c.owner_center in (:scope)
     and c.finished = 0
 order by
     c.owner_center,
     c.owner_id

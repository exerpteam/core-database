-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p2.CENTER ||'p'|| p2.id,
     p2.FULLNAME as "Member Name",
     p1.CENTER||'p'||p1.id as "other Payer ID",
     p1.FULLNAME as "Other Payer Name",
     r.rtype
 FROM
     RELATIVES r
 left JOIN
     PERSONS p1
 ON
     p1.CENTER = r.CENTER
     AND p1.id = r.id
 left JOIN
   PERSONS p2
 ON
     p2.CENTER = r.RELATIVECENTER
     AND p2.id = r.RELATIVEID
 WHERE
   r.RTYPE = 12 and
      r.STATUS = 1
   and   (p1.center,p1.id) in (:person)

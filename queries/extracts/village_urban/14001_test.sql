-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     scl.key,
     rel.RELATIVECENTER || 'p' || rel.RELATIVEID PersonKey,
     rel.CENTER || 'p' || rel.ID                 friendKey,
     p.FIRSTNAME         friendFirstName,
     c.SHORTNAME  CenterName
 FROM
     RELATIVES rel
 JOIN
     STATE_CHANGE_LOG scl
 ON
     scl.ENTRY_TYPE = 4
     AND scl.CENTER = rel.CENTER
     AND scl.ID = rel.ID
     AND scl.SUBID = rel.SUBID
 JOIN
     PERSONS p
 ON
     p.CENTER = rel.CENTER
     AND p.id = rel.ID
 JOIN
     CENTERS c
 ON 
     rel.CENTER = c.ID
 WHERE
     rel.RTYPE = 13
     AND scl.STATEID = 1
     AND p.STATUS IN (1,3)
     AND scl.ENTRY_START_TIME >= CAST(dateToLongC(to_date(getcentertime(c.ID),'YYYY-MM-DD')  || ' 00:00',c.ID)-24*60*60*1000 AS BIGINT)
     AND scl.ENTRY_START_TIME < CAST(dateToLongC(to_date(getcentertime(c.ID),'YYYY-MM-DD') || ' 00:00',c.ID) AS BIGINT)
    AND scl.ENTRY_END_TIME IS NULL
     AND p.CENTER = :center
    
    
   -- WHERE c.subscription_id = 6853
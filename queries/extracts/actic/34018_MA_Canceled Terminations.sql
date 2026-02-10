-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
c.name,  
j.PERSON_CENTER || 'p' || j.PERSON_ID PERSONID, 
j.CREATORCENTER || 'P' || j.CREATORID CREATORID, 
j.NAME,
j.JETYPE,
TO_CHAR(longtodate(j.CREATION_TIME), 'YYYY-MM-DD') CREATION_DATE 

From JOURNALENTRIES j

JOIN centers c
on c.id = j.PERSON_CENTER


WHERE  j.PERSON_CENTER IN (:Scope)
AND j.JETYPE = 19
AND j.CREATION_TIME >= :FromDate
AND j.CREATION_TIME < :ToDate + (1000*60*60*24)


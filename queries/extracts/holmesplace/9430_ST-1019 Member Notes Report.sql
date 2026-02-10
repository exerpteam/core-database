-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT p.CENTER || 'p' || p.ID AS MemberId,
       p.FULLNAME AS MemberName,
       je.NAME AS Subject,   
       UTL_I18N.RAW_TO_CHAR(dbms_lob.substr (je.BIG_TEXT,2000,1), 'UTF8') AS Details
FROM PERSONS p
JOIN JOURNALENTRIES je on p.CENTER = je.PERSON_CENTER and p.ID=je.PERSON_ID
WHERE 
        p.STATUS IN (1,3)
        AND je.JETYPE = 3
        AND longtodate(je.CREATION_TIME)>add_months(SYSDATE,-3)
		AND p.CENTER IN ($$scope$$)
		AND ('ALL' in ($$memberList$$) or p.CENTER || 'p' || p.ID IN ($$memberList$$))
		
ORDER BY 
        p.CENTER, 
        p.ID,
        je.CREATION_TIME DESC
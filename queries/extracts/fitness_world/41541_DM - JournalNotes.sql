-- This is the version from 2026-02-05
--  
SELECT
    p.center || 'p' || p.id AS PERSONID,
    TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'yyyy-MM-dd HH24:MI:SS')  AS CREATIONDATE,    
    jrn.name                AS Header,
    UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(jrn.big_text, 4000,1), 'UTF8') AS TEXT,
    jrnCreator.fullname AS CREATORNAME
FROM
    journalentries jrn
JOIN
    persons p
ON
    p.center = jrn.person_center
    AND p.id = jrn.person_id
join
   employees emp
on
  emp.center = jrn.creatorcenter
  and emp.id = jrn.creatorid      
JOIN 
    persons jrnCreator
ON
    jrnCreator.center = emp.personcenter
    AND jrnCreator.id = emp.personid
WHERE
    p.CENTER IN ($$scope$$)

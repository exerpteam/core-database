-- This is the version from 2026-02-05
--  
SELECT DISTINCT 
       p.CENTER || 'p' || p.id AS MEMBERID,
       curr_p.EXTERNAL_ID,
       CASE p.STATUS
           WHEN 0 THEN 'LEAD'
           WHEN 1 THEN 'ACTIVE'
           WHEN 2 THEN 'INACTIVE'
           WHEN 3 THEN 'TEMPORARY INACTIVE'
           WHEN 4 THEN 'TRANSFERRED'
           WHEN 5 THEN 'DUPLICATE'
           WHEN 6 THEN 'PROSPECT'
           WHEN 7 THEN 'DELETED'
           WHEN 8 THEN 'ANONYMIZED'
           WHEN 9 THEN 'CONTACT'
           ELSE 'Undefined'
       END AS "MEMBER STATUS",
       cd.CODE AS CAMPAIGNCODE,
       pr.NAME AS SUBSCRIPTION,
       CASE s.STATE
           WHEN 2 THEN 'ACTIVE'
           WHEN 3 THEN 'ENDED'
           WHEN 4 THEN 'FROZEN'
           WHEN 7 THEN 'WINDOW'
           WHEN 8 THEN 'CREATED'
           ELSE 'OTHER'
       END AS "SUBSCRIPTION STATE",
       s.START_DATE AS STARTDATE,
       s.END_DATE AS ENDDATE,
       s.BINDING_END_DATE,
       p.firstname || ' ' || p.lastname AS Name,
       s.OWNER_CENTER,
       pea.txtvalue AS email,
       TO_CHAR(longtodate(s.CREATION_TIME), 'DD-MM-YY HH24:MI:SS') AS CREATIONTIME
FROM PERSONS p
JOIN SUBSCRIPTIONS s 
  ON s.OWNER_CENTER = p.CENTER
 AND s.OWNER_ID = p.ID

-- === Kun promokoden brugt ved oprettelsen ===
JOIN PRIVILEGE_USAGES pu 
  ON pu.PERSON_CENTER = p.CENTER
 AND pu.PERSON_ID = p.ID
 AND ABS(pu.use_time - s.CREATION_TIME) < 300  -- 5 minutters tolerance

JOIN CAMPAIGN_CODES cd 
  ON cd.ID = pu.CAMPAIGN_CODE_ID

JOIN PERSON_EXT_ATTRS pea 
  ON pea.PERSONCENTER = p.CENTER
 AND pea.PERSONID = p.id
 AND pea.NAME = '_eClub_Email'

JOIN PRODUCTS pr 
  ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
 AND pr.ID = s.SUBSCRIPTIONTYPE_ID

JOIN PERSONS curr_p 
  ON p.CURRENT_PERSON_CENTER = curr_p.CENTER
 AND p.CURRENT_PERSON_ID = curr_p.ID

WHERE s.CREATION_TIME >= (:Oprettelses_efter)
  AND s.CREATION_TIME <= (:Oprettelse_for)
  AND cd.CODE IN (:Kode)
	AND s.state in (2,4)
ORDER BY CREATIONTIME;

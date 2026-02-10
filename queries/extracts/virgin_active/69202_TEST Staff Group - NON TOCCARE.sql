-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
         P.PERSON_ID,
         P.SCOPE_ID,
         SG.NAME                                                                
STAFF_GROUP,
         p.PERSON_CENTER || 'p' || p.person_id   STAFF_MEMBER_ID,
         p.STAFF_GROUP_ID
 FROM
         PERSON_STAFF_GROUPS P
 JOIN
         STAFF_GROUPS SG
         ON SG.ID = P.STAFF_GROUP_ID
 WHERE
      P.SCOPE_ID IN ($$Scope$$)
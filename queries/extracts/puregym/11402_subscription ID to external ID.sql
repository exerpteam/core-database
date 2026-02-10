-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     s.center||'ss'||s.id AS subscription ,
     p2.EXTERNAL_ID
 FROM
     PERSONS p
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
 JOIN
     PERSONS p2
 ON
     p2.CENTER = p.CURRENT_PERSON_CENTER
     AND p2.id = p.CURRENT_PERSON_ID
 WHERE
     (
         s.center,s.id) IN ($$membership_id$$)

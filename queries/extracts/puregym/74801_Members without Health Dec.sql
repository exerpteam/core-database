-- The extract is extracted from Exerp on 2026-02-08
-- PARQ_ACCEPTED NOT TRUE
 SELECT
     P.CENTER || 'p' || P.ID AS "MEMBERID"
 FROM
     persons p
 WHERE
     p.center IN ($$Scope$$)
     AND p.status IN ($$Status$$)
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             person_ext_attrs pe
         WHERE
             pe.personcenter = p.center
             AND pe.personid = p.id
             AND pe.name = 'PARQ_ACCEPTED'
             AND pe.txtvalue = 'true')

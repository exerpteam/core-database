 SELECT
     P.CENTER || 'p' || P.ID AS "MEMBERID"
 FROM
     persons p
 WHERE
     p.center IN ($$Scope$$)
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             person_ext_attrs pe
         WHERE
             pe.personcenter = p.center
             AND pe.personid = p.id
             AND pe.name = 'Pinnotification'
             AND pe.txtvalue = '0')

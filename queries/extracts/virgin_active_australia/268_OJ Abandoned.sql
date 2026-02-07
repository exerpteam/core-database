-- This is the version from 2026-02-05
--  
 SELECT
 c.SHORTNAME AS Club,
 to_date(personCreation.txtvalue, 'YYYY-MM-DD')  AS CreationDate,
 p.center||'p'||p.id   AS MembershipNbr,
 p.external_id,
 CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
 CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS STATUS,
 p.FIRSTNAME,
 p.LASTNAME,
 p.ADDRESS1,
 p.ADDRESS2,
 p.ADDRESS3,
 p.ZIPCODE AS Postcode,
 p.CITY,
 MC.TXTVALUE AS MC,
 r.relativecenter||'p'||r.relativeid as CreateUser
 FROM
     PERSONS p
 JOIN
         CENTERS c
 ON
 P.CENTER = c.ID
 JOIN
    PERSON_EXT_ATTRS personCreation
         ON
        p.center = personCreation.PERSONCENTER
             AND
                 p.id = personCreation.PERSONID
          AND personCreation.name = 'CREATION_DATE'
 LEFT JOIN
 PERSON_EXT_ATTRS MC
 ON
  p.center = MC.PERSONCENTER
  AND
 p.id = MC.PERSONID
          AND
 MC.name = 'MC'
 JOIN
 relatives r
 on
 p.center = r.center
 and
 p.id = r.id
 WHERE
     p.STATUS in (0, 4, 6, 9)
 AND
 to_date(personCreation.txtvalue, 'YYYY-MM-DD') BETWEEN $$from_date$$ AND $$to_date$$
 AND
 p.center in ($$scope$$)
 and
 r.relativecenter = 100
 and
 r.relativeid = 407

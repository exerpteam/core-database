-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT c.SHORTNAME as club, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId, p.FULLNAME, e.TXTVALUE as numero, e1.TXTVALUE as posizione, e2.TXTVALUE as dataScadenza  FROM PERSON_EXT_ATTRS e
 INNER JOIN PERSONS p
 ON
 p.ID = e.PERSONID
 AND
 p.CENTER = e.PERSONCENTER
 and e.NAME = 'Locker_Number'
 INNER JOIN CENTERS c
 on c.ID = p.CENTER
 INNER JOIN
 PERSON_EXT_ATTRS e1
 ON
 p.ID = e1.PERSONID
 AND
 p.CENTER = e1.PERSONCENTER
 and e1.NAME = 'Locker_Location'
 INNER JOIN
 PERSON_EXT_ATTRS e2
 ON
 p.ID = e2.PERSONID
 AND
 p.CENTER = e2.PERSONCENTER
 and e2.NAME = 'Locker_Expiry'
  WHERE
 p.CENTER = $$CENTER$$
 and (e.TXTVALUE IS NOT NULL or e.TXTVALUE IS NOT NULL or e2.TXTVALUE IS NOT NULL)
 -- and PERSONCENTER = 206
 ORDER BY c.SHORTNAME, p.FULLNAME

 SELECT
     p.FULLNAME,
     c.NAME              AS center,
     email.TXTVALUE      AS email,
     p.center||'p'||p.id AS p_ref,
     e.IDENTITY,
     COUNT(DISTINCT ch.ID)                             AS "totl attends",
     MAX(longtodatetz(ch.CHECKIN_TIME,'Europe/London')) AS "last attend"
 FROM
     persons p
 JOIN
     ENTITYIDENTIFIERS e
 ON
     e.IDMETHOD = 5
     AND e.ENTITYSTATUS = 1
     AND e.REF_CENTER = p.CENTER
     AND e.REF_ID = p.ID
     AND e.REF_TYPE = 1
 JOIN
     CHECKINS ch
 ON
     ch.PERSON_CENTER = p.center
     AND ch.PERSON_ID = p.id
     AND ch.CHECKIN_TIME BETWEEN $$from_date$$ AND $$to_date$$
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 WHERE
     e.IDENTITY IN ($$pins$$)
     group by p.FULLNAME,
     c.NAME            ,
     email.TXTVALUE     ,
     p.center,p.id,
     e.IDENTITY

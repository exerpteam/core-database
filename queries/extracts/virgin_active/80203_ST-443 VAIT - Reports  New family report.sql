 SELECT
     c1.id                      AS "CLUB REFERENTE",
     c1.NAME                    AS "CLUB NOME",
     s1.CENTER || 'ss' || s1.ID AS "NUMERO",
     p1.FULLNAME                AS "NOME DEL REFERENTE",
     atts1.TXTVALUE             AS "DATA ISCRIZIONE",
     s1.START_DATE              AS "DATA INIZIO ABBONAMENTO",
     c2.id                      AS "NUOVO SOCIO CLUB",
     s2.CENTER || 'ss' || s2.ID AS "NUOVO NUMERO ABBONAMEN",
     p2.FULLNAME                AS "NOME COGNOME",
     atts2.TXTVALUE             AS "DATA ISCRIZIONE",
     s2.START_DATE              AS "DATA INIZIO ABBONAMENTO",
	 rel.RTYPE					AS "RELATION TYPE",
	 rel.STATUS					AS "RELATION STATUS"
 FROM
     RELATIVES rel
 JOIN
     PERSONS p1
 ON
     p1.CENTER = rel.RELATIVECENTER
     AND p1.ID = rel.RELATIVEID
 JOIN
     CENTERS c1
 ON
     c1.id = p1.center
 LEFT JOIN
     SUBSCRIPTIONS s1
 ON
     s1.OWNER_CENTER = p1.CENTER
     AND s1.OWNER_ID = p1.ID
     AND s1.STATE IN (2,4,8)
 LEFT JOIN
     PERSON_EXT_ATTRS atts1
 ON
     atts1.PERSONCENTER = p1.CENTER
     AND atts1.PERSONID = p1.ID
     AND atts1.NAME = 'CREATION_DATE'
 JOIN
     PERSONS p2
 ON
     p2.CENTER = rel.CENTER
     AND p2.ID = rel.ID
 JOIN
     CENTERS c2
 ON
     c2.id = p2.center
 LEFT JOIN
     SUBSCRIPTIONS s2
 ON
     s2.OWNER_CENTER = p2.CENTER
     AND s2.OWNER_ID = p2.ID
     AND s2.STATE IN (2,4,8)
 LEFT JOIN
     PERSON_EXT_ATTRS atts2
 ON
     atts2.PERSONCENTER = p2.CENTER
     AND atts2.PERSONID = p2.ID
     AND atts2.NAME = 'CREATION_DATE'
 WHERE
     rel.RTYPE = 4
     AND rel.STATUS = 1
     AND p2.center in ($$scope$$)
     --and s2.START_DATE between (from_date) and (to_date)

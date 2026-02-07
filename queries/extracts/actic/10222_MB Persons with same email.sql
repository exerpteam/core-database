SELECT
    p1.CENTER || 'p' || p1.ID p1_id,
    pea_email.txtvalue p1_email,
    DECODE ( p1.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS p1_PERSONTYPE,
    DECODE (p1.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN')         AS p1_STATUS,
    p2.CENTER || 'p' || p2.ID p2_id,
    DECODE ( p2.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS p2_PERSONTYPE,
    DECODE (p2.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN')         AS p2_STATUS,
    p2.txtvalue p2_email

FROM
    PERSONS p1
LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p1.center
	AND pea_email.PERSONID = p1.id
	AND pea_email.NAME = '_eClub_Email'
	
JOIN
	(
		SELECT
			p.SSN,
			p.CENTER,
			p.ID,
			p.STATUS,
			p.SEX,
			p.PERSONTYPE,
			pea_email.txtvalue
		FROM
			PERSONS p
		LEFT JOIN PERSON_EXT_ATTRS pea_email
		ON
			pea_email.PERSONCENTER = p.center
			AND pea_email.PERSONID = p.id
			AND pea_email.NAME = '_eClub_Email'
	)	p2
ON
	p2.txtvalue = pea_email.txtvalue
	AND
	(
		p2.CENTER != p1.CENTER
		OR p2.ID != p1.ID
	)

WHERE
    p1.STATUS IN (0,1,2,3)
    AND p2.STATUS IN (0,1,2,3)
    AND p1.SEX != 'C'
    AND p2.SEX != 'C'
SELECT
    p.center                                                                                                                                                                          AS PersonCenter,
    p.center || 'p' || p.id                                                                                                                                                           AS PersonId,
    p.fullname                                                                                                                                                                        AS PersonName,
    p.birthdate                                                                                                                                                                       AS PersonDOB,
    p.SSN                                                                                                                                                                       	  AS PersonSSN,	
    pemail.txtvalue                                                                                                                                                                   AS PersonEmail,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PersonType,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN')   AS PersonStatus,
    dup.center                                                                                                                                                                        AS DupPersonCenter,
    dup.center || 'p' || dup.id                                                                                                                                                       AS DupPersonId,
    dup.fullname                                                                                                                                                                      AS DupPerName,
    dup.birthdate                                                                                                                                                                     AS DupPerDOB,
    dup.SSN                                                                                                                                                                           AS DupPerSSN,	
    dupemail.txtvalue                                                                                                                                                                 AS DupPerEmail,
    DECODE ( dup.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                       AS DupPersonType,
    DECODE (dup.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS DupPersonStatus
FROM
    persons p
JOIN
    persons dup
ON
    dup.center != p.center
    AND dup.id != p.id
LEFT JOIN
    PERSON_EXT_ATTRS pemail
ON
    pemail.PERSONCENTER = p.CENTER
    AND pemail.PERSONID = p.ID
    AND pemail.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS dupemail
ON
    dupemail.PERSONCENTER = dup.CENTER
    AND dupemail.PERSONID = dup.ID
    AND dupemail.NAME = '_eClub_Email'
WHERE
    p.center IN (607,608)
	AND p.SSN = dup.SSN
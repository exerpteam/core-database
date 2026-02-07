SELECT
    pea.PERSONCENTER||'p'||pea.PERSONID                                                                                                                                              AS "person id",
    pea2.TXTVALUE                                                                                                                                                                    AS "email address",
    DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown')                         AS "Person Type",
    p.COUNTRY                                                                                                                                                                        AS "person country" ,
    DECODE (p.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 5,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown') AS "Person status"
FROM
    PERSON_EXT_ATTRS pea
JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.PERSONCENTER = pea.PERSONCENTER
    AND pea.PERSONID = pea2.PERSONID
    AND pea2.NAME = '_eClub_PhoneSMS'
JOIN
    PERSONS p
ON
    p.center = pea.PERSONCENTER
    AND p.id = pea.PERSONID
WHERE
    pea.NAME = '_eClub_AllowedChannelSMS'
    AND pea.TXTVALUE = 'false'
    AND LENGTH(pea2.TXTVALUE) > 0
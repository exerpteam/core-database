-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id MemberNo,
    p.FIRSTNAME,
    p.LASTNAME,
    pea_email.txtvalue AS Email,
    p.center HomeCenter,
    p.sex                                                                                                                                           AS Gender,
    TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD')                                                                                                              AS Birthdate,
    DECODE (STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED', 'UNKNOWN') AS Status,
    p.ZIPCODE,
    NVL(pea_accept_email.txtvalue, 'FALSE')                                                                                                                             AS ReceiveEmail,
    NVL(pea_newsletter.txtvalue, 'FALSE')                                                                                                                               AS ReceiveNewsletter,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST',9,'CHILD', 'UNKNOWN') AS PERSONTYPE,
    CASE
        WHEN pea.TXTVALUE IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END AS Transferred,
    CASE
        WHEN pea.TXTVALUE IS NOT NULL
        THEN pea.TXTVALUE
        ELSE ''
    END                                                     AS TransferredTo,
    pea_trdate.TXTVALUE                                     AS TransferredDate,
    DECODE(pea_event_tag.txtvalue, 'true', 'true', 'false') AS "Fatburner bootcamp",
    DECODE(pea_event_tag3.txtvalue, 'true', 'true', 'false') AS "Event tag 3",
	DECODE(pea_event_fitnfab.txtvalue, 'true', 'true', 'false') AS "fitnfab",
    p.ADDRESS1                                              AS AddressLine1 ,
    p.ADDRESS2                                              AS AddressLine2 ,
    p.CITY                                                  AS City ,
    co.NAME                                                 AS Country ,
    p.ZIPCODE                                               AS ZipCode,
    exerpro.longtodate(p.LAST_MODIFIED) AS Last_modified
FROM
    persons p
JOIN COUNTRIES co
ON
    co.ID = p.COUNTRY
LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p.center
    AND pea_email.PERSONID = p.id
    AND pea_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS pea_newsletter
ON
    pea_newsletter.PERSONCENTER = p.center
    AND pea_newsletter.PERSONID = p.id
    AND pea_newsletter.NAME = '_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN PERSON_EXT_ATTRS pea_accept_email
ON
    pea_accept_email.PERSONCENTER = p.center
    AND pea_accept_email.PERSONID = p.id
    AND pea_accept_email.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID = p.id
    AND pea.name = '_eClub_TransferredToId'
LEFT JOIN PERSON_EXT_ATTRS pea_trdate
ON
    pea_trdate.PERSONCENTER = p.center
    AND pea_trdate.PERSONID = p.id
    AND pea_trdate.name = '_eClub_TransferDate'
LEFT JOIN PERSON_EXT_ATTRS pea_event_tag
ON
    pea_event_tag.PERSONCENTER = p.center
    AND pea_event_tag.PERSONID = p.id
    AND pea_event_tag.name = 'Event_tag2'
LEFT JOIN PERSON_EXT_ATTRS pea_event_tag3
ON
    pea_event_tag3.PERSONCENTER = p.center
    AND pea_event_tag3.PERSONID = p.id
    AND pea_event_tag3.name = 'Event_tag3'
LEFT JOIN PERSON_EXT_ATTRS pea_event_fitnfab
ON
    pea_event_fitnfab.PERSONCENTER = p.center
    AND pea_event_fitnfab.PERSONID = p.id
    AND pea_event_fitnfab.name = 'event_fitnfab'
WHERE
    p.status IN (0,1,2,3,4,6,9)
    AND p.sex != 'C'
    AND p.center NOT IN (100)
    AND p.center IN (:scope)
    AND trunc(exerpsysdate()-4) < exerpro.longtodate(p.LAST_MODIFIED) 
    AND exerpro.longtodate(p.LAST_MODIFIED) <= trunc(exerpsysdate())
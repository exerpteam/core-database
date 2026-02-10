-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    'Fitness World' as "u_brand",
    p.EXTERNAL_ID as "u_exerp_id",
    p.CITY as "u_city",
    p.COUNTRY as "u_country",
    p.FIRSTNAME as "u_firstname",
    p.CENTER ||'p'|| p.ID as "u_member_id",
    p.ADDRESS1 as "u_street",
    p.LASTNAME as "u_lastname",
    pea_2.TXTVALUE as "u_phone",
    pea.TXTVALUE as "u_email",
    p.ZIPCODE as "u_zip",
DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS, 
to_char(longtodatec(maxcheckin.lastcheckin, maxcheckin.person_center), 'dd-MM-YYYY HH24:MI')  as last_checkin_time
FROM
    persons p
left JOIN
    (
        SELECT
            ch.PERSON_CENTER,
            ch.PERSON_ID,
            MAX(ch.CHECKIN_TIME) AS lastcheckin
        FROM
            checkins ch
        GROUP BY
            ch.PERSON_CENTER,
            ch.PERSON_ID) maxcheckin
ON
    p.center = maxcheckin.PERSON_CENTER
AND p.id = maxcheckin.PERSON_ID


LEFT JOIN
    FW.PERSON_EXT_ATTRS pea
ON 
    p.CENTER = pea.PERSONCENTER
AND p.ID = pea.PERSONID
AND 
pea.NAME = '_eClub_Email'
LEFT JOIN
    FW.PERSON_EXT_ATTRS PEA_2
ON
    p.CENTER = pea_2.PERSONCENTER
AND
    p.ID = pea_2.PERSONID
AND
pea_2.NAME ='_eClub_PhoneSMS' 
WHERE
p.status NOT IN (4,5,7,8)  
AND p.CENTER IN (:Center)

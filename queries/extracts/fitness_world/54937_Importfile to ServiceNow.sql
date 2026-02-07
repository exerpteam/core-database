-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-9833
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
    p.ZIPCODE as "u_zip"
FROM
    persons p
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

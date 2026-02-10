-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS
(
        SELECT
                t1.current_person_center,
                t1.current_person_id,
                t1.name,
                t1.expiration_date,
                t1.counting AS number_valid_helthCertificates
        FROM
        (
                SELECT
                        p.current_person_center,
                        p.current_person_id, 
                        je.name,
                        je.expiration_date,
                        rank() over (partition by p.current_person_center, p.current_person_id ORDER BY je.expiration_date DESC,  je.creation_time DESC) ranking,
                        count(1) over (partition by p.current_person_center, p.current_person_id) counting
                FROM 
                        chelseapiers.persons p
                JOIN
                        chelseapiers.journalentries je 
                                ON je.person_center = p.center
                                AND je.person_id = p.id
                                AND je.jetype = 31 -- HealthCertificate 
                                AND je.expiration_date >= CURRENT_DATE
        ) t1
        WHERE
                t1.ranking = 1
)
SELECT DISTINCT
    c.name              AS "Center",
    p.center||'p'||p.id AS "Person ID",    
    p.firstname         AS "First Name",
    p.lastname          AS "Last Name",
    CASE WHEN PERSONTYPE = 0 THEN 'PRIVATE' WHEN PERSONTYPE = 1 THEN 'STUDENT' WHEN PERSONTYPE = 2 THEN 'STAFF' WHEN PERSONTYPE = 3 THEN 'FRIEND' WHEN PERSONTYPE = 4 THEN 'CORPORATE' WHEN PERSONTYPE = 5 THEN 'ONEMANCORPORATE' WHEN PERSONTYPE = 6 THEN 'FAMILY' WHEN PERSONTYPE = 7 THEN 'SENIOR' WHEN PERSONTYPE = 8 THEN 'GUEST' WHEN PERSONTYPE = 9 THEN 'CHILD' WHEN PERSONTYPE = 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type",
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person State",
    p.address1          AS "Street Address 1",
    p.address2          AS "Street Address 2",
    p.city              AS "City",
    p.zipcode           AS "Zip",
    phone.txtvalue      AS "HomePhone",
    mobile.txtvalue     AS "MobilePhone",
    email.txtvalue      AS "Email",
    par.name AS "HealthCertificate Subject",
    par.expiration_date AS "HealthCertificate ExpirationDate",
    par.number_valid_helthCertificates AS "Total Valid HealthCertificate"
FROM persons p
JOIN centers c
        ON c.id = p.center
LEFT JOIN person_ext_attrs email
        ON email.personcenter=p.center
        AND email.personid=p.id
        AND email.name = '_eClub_Email'
LEFT JOIN person_ext_attrs phone
        ON phone.personcenter=p.center
        AND phone.personid=p.id
        AND phone.name = '_eClub_PhoneHome'
LEFT JOIN person_ext_attrs mobile
        ON mobile.personcenter=p.center
        AND mobile.personid=p.id
        AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN PARAMS par
        ON par.current_person_center = p.center
        AND par.current_person_id = p.id
WHERE 
        p.center in (:Center) AND
        p.status NOT IN (4,5,7,8)
        AND p.sex != 'C'
ORDER BY 4

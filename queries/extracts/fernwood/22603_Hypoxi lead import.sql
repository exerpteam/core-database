-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.firstname
        ,p.lastname
        ,p.birthdate
        ,p.center
        ,p.id
        ,p.external_id
        ,CASE p.PERSONTYPE 
                WHEN 0 THEN 'PRIVATE' 
                WHEN 1 THEN 'STUDENT' 
                WHEN 2 THEN 'STAFF' 
                WHEN 3 THEN 'FRIEND' 
                WHEN 4 THEN 'CORPORATE' 
                WHEN 5 THEN 'ONEMANCORPORATE' 
                WHEN 6 THEN 'FAMILY' 
                WHEN 7 THEN 'SENIOR' 
                WHEN 8 THEN 'GUEST' 
                WHEN 9 THEN 'CHILD' 
                WHEN 10 THEN 'EXTERNAL_STAFF' 
                ELSE 'Undefined' 
        END AS PersonType
        ,Email.txtvalue as email
        ,phone.txtvalue as mobile
,p.*
FROM 
        persons p
JOIN 
        person_ext_attrs comment
        ON comment.personcenter = p.center
        AND comment.personid = p.id
        AND comment.name = '_eClub_Comment'
        AND comment.txtvalue = 'HYPOXI lead import'
JOIN 
        person_ext_attrs Email
        ON Email.personcenter = p.center
        AND Email.personid = p.id
        AND Email.name = '_eClub_Email'
JOIN 
        person_ext_attrs phone
        ON phone.personcenter = p.center
        AND phone.personid = p.id
        AND phone.name = '_eClub_PhoneSMS'
WHERE 
        p.persontype in (:persontype) 
        AND 
        comment.txtvalue = 'HYPOXI lead import'
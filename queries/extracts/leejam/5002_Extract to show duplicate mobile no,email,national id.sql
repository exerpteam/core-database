WITH 
eligibale_emails AS
        (
        SELECT
                *
        FROM        
                (
                SELECT
                        pea_email.txtvalue
                        ,count(*) AS nocount
                FROM
                        person_ext_attrs pea_email
                WHERE
                        pea_email.name = '_eClub_Email'  
                        AND 
                        pea_email.txtvalue IS NOT NULL
                GROUP BY 
                        pea_email.txtvalue
                )t
        WHERE
                t.nocount > 1 
        ),
eligibale_mobiles AS 
        (       
        SELECT
                *
        FROM        
                (
                SELECT
                        pea_mobile.txtvalue
                        ,count(*) AS nocount
                FROM
                        person_ext_attrs pea_mobile
                WHERE
                        pea_mobile.name = '_eClub_PhoneSMS'  
                        AND 
                        pea_mobile.txtvalue IS NOT NULL
                GROUP BY 
                        pea_mobile.txtvalue
                )t
        WHERE
                t.nocount > 1 
        ),
eligibale_NaionalID AS
        (
        SELECT
                *
        FROM        
                (
                SELECT
                        p.NATIONAL_ID
                        ,count(*) AS nocount
                FROM
                        persons p
                WHERE
                        p.NATIONAL_ID IS NOT NULL
                GROUP BY 
                        p.NATIONAL_ID
                )t
        WHERE
                t.nocount > 1 
        )        
SELECT 
        p.center||'p'||p.id AS "Member ID"
        ,p.fullname AS "Member name"
        ,pea.txtvalue AS "Email"
        ,CASE p.STATUS 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS  "Person Status"
        ,prod.name AS "Subscription name"
        ,s.start_date AS "Subscription start date"
        ,s.end_date AS "Subscription end date"
        ,s.center AS "Subscription centre id"
        ,c.name AS "Subscription centre name"
        ,p.NATIONAL_ID AS "National ID"
        ,p.RESIDENT_ID AS "Resident ID"
        ,pea_passport.txtvalue AS "Passport"
        ,pea_mobile.txtvalue AS "Mobile phone"
        ,CASE s.STATE 
                WHEN 2 THEN 'ACTIVE' 
                WHEN 3 THEN 'ENDED' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE '' 
        END AS "Subscription Status"	
        ,je.creatorcenter||'emp'||je.creatorid AS "Created by"
        ,'Dulicate Email'AS Duplication
FROM
        persons p
JOIN
        person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'  
        AND pea.txtvalue IS NOT NULL
JOIN
        eligibale_emails dup_email
        ON dup_email.txtvalue = pea.txtvalue
LEFT JOIN
        subscriptions s 
        ON s.owner_Center=p.center 
        AND s.owner_id = p.id 
        AND s.state in (2,4,8) 
LEFT JOIN
        subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
LEFT JOIN
        products prod
        ON prod.center = st.center
        AND prod.id = st.id   
LEFT JOIN
        centers c 
        ON c.id = s.center  
LEFT JOIN
        person_ext_attrs pea_passport 
        ON pea_passport.personcenter = p.center 
        AND pea_passport.personid = p.id  
        AND pea_passport.name = '_eClub_PassportNumber' 
LEFT JOIN
        person_ext_attrs pea_mobile 
        ON pea_mobile.personcenter = p.center 
        AND pea_mobile.personid = p.id  
        AND pea_mobile.name =  '_eClub_PhoneSMS' 
LEFT JOIN
        journalentries je
        ON je.person_Center = p.center 
        AND je.person_id = p.id 
        AND je.jetype = 3         
        AND je.name = 'Person created'     
UNION ALL
SELECT 
        p.center||'p'||p.id AS "Member ID"
        ,p.fullname AS "Member name"
        ,pea_email.txtvalue AS "Email"
        ,CASE p.STATUS 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS  "Person Status"
        ,prod.name AS "Subscription name"
        ,s.start_date AS "Subscription start date"
        ,s.end_date AS "Subscription end date"
        ,s.center AS "Subscription centre id"
        ,c.name AS "Subscription centre name"
        ,p.NATIONAL_ID AS "National ID"
        ,p.RESIDENT_ID AS "Resident ID"
        ,pea_passport.txtvalue AS "Passport"
        ,pea.txtvalue AS "Mobile phone"
        ,CASE s.STATE 
                WHEN 2 THEN 'ACTIVE' 
                WHEN 3 THEN 'ENDED' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE '' 
        END AS "Subscription Status"	
        ,je.creatorcenter||'emp'||je.creatorid AS "Created by"
        ,'Dulicate Mobile'AS Duplication
FROM
        persons p
JOIN
        person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_PhoneSMS'  
        AND pea.txtvalue IS NOT NULL
JOIN
        eligibale_mobiles dup_mobile
        ON dup_mobile.txtvalue = pea.txtvalue
LEFT JOIN
        subscriptions s 
        ON s.owner_Center=p.center 
        AND s.owner_id = p.id 
        AND s.state in (2,4,8) 
LEFT JOIN
        subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
LEFT JOIN
        products prod
        ON prod.center = st.center
        AND prod.id = st.id   
LEFT JOIN
        centers c 
        ON c.id = s.center  
LEFT JOIN
        person_ext_attrs pea_passport 
        ON pea_passport.personcenter = p.center 
        AND pea_passport.personid = p.id  
        AND pea_passport.name = '_eClub_PassportNumber' 
LEFT JOIN
        person_ext_attrs pea_email
        ON pea_email.personcenter = p.center 
        AND pea_email.personid = p.id  
        AND pea_email.name =  '_eClub_Email' 
LEFT JOIN
        journalentries je
        ON je.person_Center = p.center 
        AND je.person_id = p.id 
        AND je.jetype = 3         
        AND je.name = 'Person created'          
UNION ALL
SELECT 
        p.center||'p'||p.id AS "Member ID"
        ,p.fullname AS "Member name"
        ,pea.txtvalue AS "Email"
        ,CASE p.STATUS 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS  "Person Status"
        ,prod.name AS "Subscription name"
        ,s.start_date AS "Subscription start date"
        ,s.end_date AS "Subscription end date"
        ,s.center AS "Subscription centre id"
        ,c.name AS "Subscription centre name"
        ,p.NATIONAL_ID AS "National ID"
        ,p.RESIDENT_ID AS "Resident ID"
        ,pea_passport.txtvalue AS "Passport"
        ,pea_mobile.txtvalue AS "Mobile phone"
        ,CASE s.STATE 
                WHEN 2 THEN 'ACTIVE' 
                WHEN 3 THEN 'ENDED' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE '' 
        END AS "Subscription Status"	
        ,je.creatorcenter||'emp'||je.creatorid AS "Created by"
        ,'Dulicate NationalID'AS Duplication
FROM
        persons p
JOIN
        person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'  
        AND pea.txtvalue IS NOT NULL
JOIN
        eligibale_NaionalID dup_nationalID
        ON dup_nationalID.National_ID = p.National_ID
LEFT JOIN
        subscriptions s 
        ON s.owner_Center=p.center 
        AND s.owner_id = p.id 
        AND s.state in (2,4,8) 
LEFT JOIN
        subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
LEFT JOIN
        products prod
        ON prod.center = st.center
        AND prod.id = st.id   
LEFT JOIN
        centers c 
        ON c.id = s.center  
LEFT JOIN
        person_ext_attrs pea_passport 
        ON pea_passport.personcenter = p.center 
        AND pea_passport.personid = p.id  
        AND pea_passport.name = '_eClub_PassportNumber' 
LEFT JOIN
        person_ext_attrs pea_mobile 
        ON pea_mobile.personcenter = p.center 
        AND pea_mobile.personid = p.id  
        AND pea_mobile.name =  '_eClub_PhoneSMS' 
LEFT JOIN
        journalentries je
        ON je.person_Center = p.center 
        AND je.person_id = p.id 
        AND je.jetype = 3         
        AND je.name = 'Person created'   
WITH 
        HYPOXI AS
                (
                SELECT
                        p.external_id
                        ,'sub' as type
                FROM
                        fernwood.subscriptions s
                JOIN
                        fernwood.subscriptiontypes st
                        ON st.center = s.subscriptiontype_center
                        AND st.id = s.subscriptiontype_id
                JOIN
                        fernwood.products prod
                        ON prod.center = st.center
                        AND prod.id = st.id     
                JOIN
                        fernwood.product_and_product_group_link pgl
                        ON pgl.product_center = prod.center  
                        AND pgl.product_id = prod.id
                        AND pgl.product_group_id = 235
                JOIN
                        fernwood.persons p
                        ON p.center = s.owner_center
                        AND p.id = s.owner_id
                WHERE
                        p.center in (:Center)               
                UNION ALL
                SELECT
                        p.external_id
                        ,'cc' as type
                FROM 
                        fernwood.clipcards cc
                JOIN 
                        fernwood.persons p 
                        ON cc.owner_center = p.center 
                        AND cc.owner_id = p.id
                JOIN 
                        fernwood.products prod 
                        ON prod.center = cc.center
                        AND prod.id = cc.ID 
                JOIN
                        fernwood.product_and_product_group_link pgl
                        ON pgl.product_center = prod.center  
                        AND pgl.product_id = prod.id
                        AND pgl.product_group_id = 235  
                WHERE
                        p.center in (:Center)
                ),
        HYPOXI_PRODUCTS AS
                (
                SELECT 
                        prod.center
                        ,prod.id 
                FROM
                        fernwood.products prod   
                JOIN
                        fernwood.product_and_product_group_link pgl
                        ON pgl.product_center = prod.center  
                        AND pgl.product_id = prod.id
                        AND pgl.product_group_id = 235
                ),
        HYPOXI_NO_FITNESS AS
                (                                                                                                              
                SELECT
                        hp.external_id AS personID
                FROM
                        HYPOXI hp
                LEFT JOIN                        
                        (
                        SELECT
                                p.external_id
                                ,'sub' as type
                        FROM
                                fernwood.subscriptions s
                        JOIN
                                fernwood.subscriptiontypes st
                                ON st.center = s.subscriptiontype_center
                                AND st.id = s.subscriptiontype_id
                        JOIN
                                fernwood.products prod
                                ON prod.center = st.center
                                AND prod.id = st.id     
                        LEFT JOIN
                                HYPOXI_PRODUCTS hprod
                                ON hprod.center = prod.center
                                AND hprod.id = prod.id
                        JOIN
                                fernwood.persons p
                                ON p.center = s.owner_center
                                AND p.id = s.owner_id     
                        WHERE
                                p.center in (:Center)
                                and 
                                hprod.center IS NULL          
                        UNION ALL
                        SELECT
                                p.external_id
                                ,'cc' as type
                        FROM 
                                fernwood.clipcards cc
                        JOIN 
                                fernwood.persons p 
                                ON cc.owner_center = p.center 
                                AND cc.owner_id = p.id
                        JOIN 
                                fernwood.products prod 
                                ON prod.center = cc.center
                                AND prod.id = cc.ID 
                        LEFT JOIN
                                HYPOXI_PRODUCTS hprod
                                ON hprod.center = prod.center
                                AND hprod.id = prod.id         
                        WHERE
                                p.center in (:Center)
                                AND 
                                hprod.center IS NULL
                        )t  
                        ON hp.external_id = t.external_id           
                WHERE
                        t.external_id IS NULL
                ),
        Attendance AS
                (
                SELECT  
                        max(ck.checkin_time) AS LastVisitDate
                        ,ck.person_center AS PersonCenter
                        ,ck.person_id AS PersonID
                FROM 
                        fernwood.checkins ck  
                GROUP BY 
                        person_center
                        ,person_id 
                )                 
SELECT DISTINCT
        c.name AS "Club Name"
        ,p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Member Name"
        ,CASE p.status 
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
        END AS "Person status"
        ,peeaEmail.txtvalue AS "Email address"
        ,longtodatec(a.LastVisitDate,a.PersonCenter) AS "Last visit date"
FROM
        HYPOXI_NO_FITNESS hnf
JOIN
        fernwood.persons p
        ON p.external_id = hnf.personID
JOIN
        fernwood.centers c
        ON c.id = p.center        
LEFT JOIN 
        fernwood.person_ext_attrs peeaEmail
        ON peeaEmail.personcenter = p.center
        AND peeaEmail.personid = p.id
        AND peeaEmail.name = '_eClub_Email'
LEFT JOIN
        Attendance a
        ON a.PersonCenter = p.center
        AND a.PersonID = p.id          
WHERE
        p.status IN (:MemberStatus)         
                                                                                                          
-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
        params AS MATERIALIZED
                (
                        SELECT
                                c.id AS center_id,
                                datetolongC(
                                        TO_CHAR(
                                                TO_DATE(getcentertime(c.id),'YYYY-MM-DD') - INTERVAL '56 days',
                                                'YYYY-MM-DD HH24:MI'
                                        ),
                                        c.id
                                ) AS cut_date
                        FROM
                                centers c
                ),
        checkins_all AS
                (                
                        SELECT DISTINCT 
                                CAST(list.checkin AS DATE) AS checkin_time
                                ,list.person_center
                                ,list.person_id
                                ,list.checkin_center
                        FROM
                                (                                
                                SELECT  
                                        longtodatec(ck.checkin_time,ck.checkin_center) AS checkin
                                        ,ck.person_center
                                        ,ck.person_id
                                        ,ck.checkin_center
                                FROM 
                                        checkins ck
                                JOIN
                                        params par
                                        ON par.center_id = ck.checkin_center  
                                WHERE
                                        ck.checkin_time > par.cut_date
                                )list                                        
                ),
        eligible_members AS
                        (
                        SELECT DISTINCT 
                                p.center
                                ,p.id
                                ,p.external_id
                                ,minimum_checkin.checkins
                        FROM
                                persons p
                        JOIN
                                subscriptions s
                                ON s.owner_center = p.center
                                AND s.owner_id = p.id
                                AND s.end_date IS NULL
                        JOIN
                                centers c
                                ON c.id = p.center
                        JOIN
                                (
                                SELECT
                                        *
                                FROM
                                        (                                        
                                        SELECT 
                                                COUNT(ck.checkin_time) AS checkins
                                                ,ck.person_center
                                                ,ck.person_id
                                        FROM
                                                checkins_all ck
                                        JOIN
                                                centers c
                                                ON c.id = ck.person_center                                                        
                                        GROUP BY
                                                ck.person_center
                                                ,ck.person_id
                                        )mc
                                WHERE
                                        mc.checkins > 7                                                                                                                              
                                )minimum_checkin
                                ON minimum_checkin.person_center = p.center
                                AND minimum_checkin.person_id = p.id
                        WHERE
                                CAST(getcentertime(c.id) AS DATE) - s.start_date > 57
                                AND p.status = 1
                                AND p.persontype != 2
                        ),
        checkins_other AS
                        (
                        WITH 
                                checkins AS
                                (
                                SELECT
                                        COUNT(ck.checkin_time) AS checkins
                                        ,ck.checkin_center
                                        ,ck.person_center
                                        ,ck.person_id
                                FROM
                                        checkins_all ck      
                                WHERE
                                        ck.person_center != ck.checkin_center 
                                GROUP BY
                                        ck.checkin_center
                                        ,ck.person_center
                                        ,ck.person_id
                                ),
                                max_checkins AS
                                (
                                SELECT
                                        MAX(t.checkins) AS max_checkins
                                        ,t.person_center
                                        ,t.person_id               
                                FROM  
                                        checkins t
                                GROUP BY
                                        t.person_center
                                        ,t.person_id 
                                )
                                SELECT 
                                        ck.checkins
                                        ,ck.checkin_center
                                        ,ck.person_center
                                        ,ck.person_id
                                FROM 
                                        checkins ck
                                JOIN
                                        max_checkins mck
                                        ON mck.max_checkins = ck.checkins
                                        AND mck.person_center = ck.person_center
                                        AND mck.person_id = ck.person_id
                        ),
        checkins_home AS
                        (
                        SELECT
                                COUNT(ck.checkin_time) AS checkins
                                ,ck.checkin_center
                                ,ck.person_center
                                ,ck.person_id
                        FROM
                                checkins_all ck       
                        WHERE
                                ck.person_center = ck.checkin_center  
                        GROUP BY
                                ck.checkin_center
                                ,ck.person_center
                                ,ck.person_id 
                        ),
        previous_transfer AS
                        (
                        SELECT
                                p.current_person_center
                                ,p.current_person_id
                                ,p.external_id
                                ,trd.txtvalue
                        FROM
                                persons p
                        JOIN
                                eligible_members em
                                ON em.center = p.center
                                AND em.id = p.id                                
                        JOIN
                                persons transfer
                                ON transfer.current_person_center = em.center
                                AND transfer.current_person_id = em.id        
                        JOIN
                                person_ext_attrs trd
                                ON trd.personcenter= transfer.CENTER
                                AND trd.personid = transfer.id
                                AND trd.NAME = '_eClub_TransferDate' 
                        JOIN
                                PERSON_EXT_ATTRS pea
                                ON pea.PERSONCENTER= transfer.CENTER
                                AND pea.PERSONID= transfer.ID
                                AND pea.NAME = '_eClub_TransferredToId'        
                        WHERE
                                CAST(getcentertime(p.center) AS DATE) - CAST(trd.txtvalue AS DATE) < 57 
                        ),
        open_cashccollection AS
                        (
                        SELECT 
                                em.external_id
                                ,em.center
                                ,em.id
                        FROM
                                cashcollectioncases ccc
                        JOIN
                                eligible_members em
                                ON em.center = ccc.personcenter
                                AND em.id = ccc.personid       
                        WHERE
                                ccc.closed = FALSE   
                        ),
        product_group AS
                        (                        
                        SELECT
                                pgl.product_center
                                ,pgl.product_id 
                        FROM
                                product_and_product_group_link pgl       
                        WHERE
                                pgl.product_group_id in (7,237,401) 
                        ),
        relatives AS
                        (
                        SELECT
                                p.center
                                ,p.id
                                ,STRING_AGG((prel.center||'p'||prel.id),', ') as childid
                        FROM
                                persons p
                        JOIN
                                eligible_members em
                                ON em.center = p.center
                                AND em.id = p.id       
                        JOIN
                                relatives rel
                                ON rel.center = em.center
                                AND rel.id = em.id 
                                AND rel.rtype in (4,5)
                        JOIN
                                persons prel
                                ON prel.center = rel.relativecenter
                                AND prel.id = rel.relativeid
                        GROUP BY
                                p.center
                                ,p.id 
                        ),
        Installment_plan AS
                        (
                        SELECT
                                p.center 
                                ,p.id
                                ,p.external_ID
                                ,ip.id as ip_id
                        FROM 
                                installment_plans ip
                        JOIN
                                installment_plan_configs ipc
                                ON ipc.id = ip.ip_config_id
                        JOIN
                                persons p
                                ON p.center = ip.person_center
                                AND p.id = ip.person_id 
                        JOIN
                                account_receivables ar
                                ON ar.customercenter = ip.person_center
                                AND ar.customerid = ip.person_id 
                                AND ar.ar_type = 6                                                                          
                        WHERE  
                                ar.balance < 0
                                AND ip.end_date >= current_date 
                        ),
        ranked AS (
            SELECT 
                    em.center||'p'||em.id AS "PersonID"
                    ,em.external_id AS "ExternalID"
                    ,c.shortname AS "Current Home Club Name"
                    ,c.id AS "Current Home Club ID"
                    ,newc.shortname AS "New Home Club Name"
                    ,newc.id AS "New Home Club Center ID"
                    ,prod.name AS "Current Subscription Name"
                    ,s.center||'ss'||s.id AS "Subscription ID"
                    ,rel.childid AS "Relations"  
                    ,ckh.checkins AS "Home Club Checkins" 
                    ,cko.checkins AS "Other Club checkins"
                    ,ROW_NUMBER() OVER (
                        PARTITION BY c.id
                        ORDER BY cko.checkins DESC
                    ) AS rn
            FROM
                    eligible_members em       
            JOIN
                    subscriptions s
                    ON s.owner_center = em.center
                    AND s.owner_id = em.id
                    AND s.end_date IS NULL
            JOIN 
                    subscriptiontypes st
                    ON st.center = s.subscriptiontype_center
                    AND st.id = s.subscriptiontype_id 
            JOIN 
                    products prod
                    ON prod.center = st.center
                    AND prod.id = st.id
            LEFT JOIN
                    checkins_home ckh
                    ON ckh.person_center = em.center
                    AND ckh.person_id = em.id  
            LEFT JOIN
                    checkins_other cko
                    ON cko.person_center = em.center
                    AND cko.person_id = em.id 
            LEFT JOIN
                    open_cashccollection cc
                    ON cc.center = em.center
                    AND cc.id = em.id 
            LEFT JOIN
                    relatives rel
                    ON rel.center = em.center
                    AND rel.id = em.id
            JOIN
                    centers c 
                    ON c.id = em.center
            JOIN
                    centers newc
                    ON newc.id = cko.checkin_center 
            LEFT JOIN
                    Installment_plan ip
                    ON ip.center = em.center
                    AND ip.id = em.id                                                               
            WHERE
                    COALESCE(ckh.checkins, 0) < COALESCE(cko.checkins, 0)  
                    AND em.external_id NOT IN (
                        SELECT previous_transfer.external_id 
                        FROM previous_transfer
                    ) 
                    AND cc.external_id IS NULL
                    AND prod.center||'prod'||prod.id NOT IN (
                        SELECT pg.product_center||'prod'||pg.product_id 
                        FROM product_group pg
                    )   
                    AND ip.ip_id IS NULL
        )
SELECT 
        "PersonID"
        ,"ExternalID"
        ,"Current Home Club Name"
        ,"Current Home Club ID"
        ,"New Home Club Name"
        ,"New Home Club Center ID"
        ,"Current Subscription Name"
        ,"Subscription ID"
        ,"Relations"
        ,"Home Club Checkins"
        ,"Other Club checkins"
FROM ranked
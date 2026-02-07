WITH 
        params AS MATERIALIZED
                (
                        SELECT
                                c.id AS center_id,
                                TO_DATE(getcentertime(c.id),'YYYY-MM-DD') - INTERVAL '14 days' AS from_date,
                                TO_DATE(getcentertime(c.id),'YYYY-MM-DD') AS to_date
                        FROM
                                fernwood.centers c
                
                ),
        subscription_freeze AS
                (
                        SELECT DISTINCT
                                s.center
                                ,s.id
                        FROM
                                fernwood.subscriptions s
                        JOIN        
                                fernwood.subscription_reduced_period srp
                                ON s.center = srp.subscription_center
                                AND s.id = srp.subscription_id
                        JOIN
                                fernwood.centers c
                                ON c.id = s.center 
                        JOIN
                                params par
                                ON par.center_id = c.id               
                        WHERE
                                srp.state = 'ACTIVE'
                                AND
                                srp.type = 'FREEZE'
                                AND
                                srp.end_date BETWEEN par.from_date AND par.to_date
                ),
        open_tasks AS
                (
                        SELECT DISTINCT
                                p.external_id
                        FROM 
                                fernwood.tasks task
                        JOIN
                                fernwood.task_types tt
                                ON tt.id = task.type_id
                                AND tt.external_id IN ('NAW_V1')
                        JOIN
                                fernwood.persons p
                                ON p.center = task.person_center
                                AND p.id = task.person_id                                               
                        WHERE 
                                task.status NOT IN ('CLOSED','DELETED')  
                ),                         
        eligible_members AS
                (
                        SELECT DISTINCT
                                p.center
                                ,p.id 
                                ,p.external_id                                
                        FROM
                                fernwood.persons p
                        JOIN
                                fernwood.subscriptions s
                                ON s.owner_center = p.center
                                AND s.owner_id = p.id      
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
                                AND pgl.product_group_id = 5601 
                        JOIN
                                fernwood.centers c
                                ON c.id = p.center                                              
                        WHERE
                                p.status = 1
                                AND
                                p.persontype NOT IN (2,3,6,9,10)
                                AND
                                s.subscription_price != 0
                                AND
                                (TO_DATE(getcentertime(c.id),'YYYY-MM-DD') - p.birthdate)/365 > 18
                                AND
                                NOT EXISTS
                                        (
                                        SELECT
                                                *
                                        FROM
                                                subscription_freeze sf
                                        WHERE
                                                sf.center = s.center
                                                AND
                                                sf.id = s.id
                                        )
                                AND
                                NOT EXISTS
                                        (
                                         SELECT 
                                                *
                                         FROM
                                                open_tasks ot
                                         WHERE
                                                ot.external_id = p.external_id
                                        )                                                      
                ),
        checkins_14days AS
                (
                        SELECT 
                                *
                        FROM
                                (
                                        SELECT DISTINCT 
                                                p.external_id
                                                ,MAX(ck.checkin_time) AS checkin_time
                                                ,ck.checkin_center
                                                ,c.id
                                        FROM 
                                                fernwood.checkins ck
                                        JOIN
                                                fernwood.persons p
                                                ON p.center = ck.person_center
                                                AND p.id = ck.person_id
                                        JOIN
                                                fernwood.centers c
                                                ON c.id = ck.checkin_center
                                        JOIN
                                                eligible_members em
                                                ON em.center = p.center
                                                AND em.id = p.id 
                                        GROUP BY
                                                p.external_id
                                                ,ck.checkin_center
                                                ,c.id
                                )t                                        
                        WHERE
                                CAST(getcentertime(t.id) AS DATE) - CAST((longtodatec(t.checkin_time,t.checkin_center)) AS DATE) = 14
        
                )                                                            
SELECT 
        p.center||'p'||p.id AS PersonID
        ,p.external_id
FROM
        eligible_members p             
WHERE
        EXISTS
        (
                SELECT
                        *
                FROM
                        checkins_14days ck
                WHERE
                        ck.external_id = p.external_id                                                  
        )
ORDER BY 1                    
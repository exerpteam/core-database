WITH params AS MATERIALIZED
(
        SELECT
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                (datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS ToDate,
                :API_user AS API_User
        FROM
                centers c
),
created_class AS
(
        SELECT
                t.year_month
                ,t.center
                ,count(*) as total_count
                ,'Created Class' AS type
        FROM
        (        
                SELECT
                        TO_CHAR(CAST((longtodatec(b.starttime,b.center)) AS DATE), 'YYYY-MM') AS year_month
                        ,b.center
                FROM bookings b
                JOIN params
                        ON params.center_id = b.center        
                WHERE
                        b.creator_center||'p'||b.creator_id = params.API_User
                        AND b.center IN (:Scope)
                        AND b.starttime between params.FromDate and params.ToDate
        )t
        GROUP BY
                t.year_month
                ,t.center
),
created_participation_classes AS
(
        SELECT
                t.year_month
                ,t.center
                ,count(*) as total_count
                ,'Created Participation in classes' AS type
        FROM
        (        
                SELECT 
                        TO_CHAR(CAST((longtodatec(p.creation_time,p.center)) AS DATE), 'YYYY-MM') AS year_month
                        ,p.center
                FROM participations p
                JOIN params
                        on params.center_id = p.center 
                JOIN bookings b
                        ON b.center = p.booking_center
                        AND b.id = p.booking_id
                JOIN activity ac
                        ON b.activity = ac.id
                        AND ac.activity_type != 4                                               
                WHERE
                        p.creation_by_center||'p'||p.creation_by_id = params.API_User
                        AND p.center in (:Scope) 
                        AND p.creation_time between params.FromDate and params.ToDate
        )t
        GROUP BY
                t.year_month
                ,t.center 
),
created_staff_booking AS                                                                                                                       
(
        SELECT
                t.year_month
                ,t.center
                ,count(*) as total_count
                ,'Created Staff booking' AS type
        FROM
        (        
                SELECT 
                        TO_CHAR(CAST((longtodatec(p.creation_time,p.center)) AS DATE), 'YYYY-MM') AS year_month
                        ,p.center
                FROM participations p
                JOIN params
                        on params.center_id = p.center    
                JOIN bookings b
                        ON b.center = p.booking_center
                        AND b.id = p.booking_id
                JOIN activity ac
                        ON b.activity = ac.id
                        AND ac.activity_type = 4                                                   
                WHERE
                        p.creation_by_center||'p'||p.creation_by_id = params.API_User
                        AND p.center IN (:Scope)
                        AND p.creation_time between params.FromDate and params.ToDate
        )t
        GROUP BY
                t.year_month
                ,t.center  
)
SELECT
        t."Year-Month" 
        ,Count(t.id) as "Club Count"
        ,SUM(t."Created Class") AS "Created Class"
        ,SUM(t."Created Participation in classes") AS "Created Participation in classes"
        ,SUM(t."Created Staff booking") AS "Created Staff booking"
FROM
        (
        SELECT
                c.name
                ,c.id
                ,TO_CHAR(CAST((dcal.gen_ser) AS DATE), 'YYYY-MM') AS "Year-Month" 
                ,cc.total_count AS "Created Class"
                ,cpc.total_count AS "Created Participation in classes"
                ,csb.total_count AS "Created Staff booking"
        FROM centers c
        CROSS JOIN
        (
                SELECT 
                        CAST(generate_series(CAST(:From AS DATE) , CAST(:To AS DATE), '1 month') AS DATE) AS gen_ser
        )dcal                
        LEFT JOIN       
                Created_class cc
                ON cc.center = c.id
                AND TO_CHAR(dcal.gen_ser, 'YYYY-MM') = cc.year_month
        LEFT JOIN
                Created_participation_classes cpc
                ON cpc.center = c.id
                AND TO_CHAR(dcal.gen_ser, 'YYYY-MM') = cpc.year_month
        LEFT JOIN
                created_staff_booking csb
                ON csb.center = c.id
                AND TO_CHAR(dcal.gen_ser, 'YYYY-MM') = csb.year_month                  
        WHERE
                c.id IN (:Scope)
                AND
                c.startupdate < :To 
)t
GROUP BY 
        t."Year-Month"       
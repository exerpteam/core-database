-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-5835
SELECT 
        t."Club Name"
        ,t."Club ID"
        ,t."Date From"
        ,t."Date To"
        ,Count(t."Person ID") AS "Number of active members"
FROM
        (        
        WITH
                  params AS
                  (
                      SELECT
                          /*+ materialize */
                          CAST(:FromDate AS DATE) AS FromDate,
                          c.id AS CENTER_ID,
                          CAST(:ToDate AS DATE) AS ToDate
                      FROM
                          centers c
                  )
        SELECT DISTINCT
                c.shortname                             AS "Club Name"
                ,c.id                                   AS "Club ID"
                ,params.FromDate                        AS "Date From"
                ,params.ToDate                          AS "Date To"
                ,s.owner_center||'p'||s.owner_id        AS "Person ID"        
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                        ON st.center = s.subscriptiontype_center
                        AND st.id = s.subscriptiontype_id
        JOIN
                product_and_product_group_link pgl
                        ON pgl.product_center = st.center
                        AND pgl.product_id = st.id
                        AND pgl.product_group_id = 5601
        JOIN
                products prod
                        ON prod.center = st.center
                        AND prod.id = st.id
        JOIN
                centers c
                        ON c.id = s.center 
        JOIN
                params
                        ON params.center_id = s.center                                                                                                  
        WHERE
                s.center IN (:Scope)    
                AND
                s.start_date <= params.ToDate
                AND
                (
                s.end_date IS NULL
                OR
                s.end_date >= params.FromDate
                )  
        )t 
GROUP BY
        t."Club Name"
        ,t."Club ID"
        ,t."Date From"
        ,t."Date To"                       
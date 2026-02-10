-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2470
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT DISTINCT
        t1.*
FROM
        (
        SELECT 
                c.shortname AS "Center"
                ,p.center ||'p'|| p .id AS "PersonID"
                ,p.fullname AS "Member Name"
                ,longtodatec(s.creation_time,s.center) AS "Join Date"
                ,bi_decode_field('PERSONS', 'PERSONTYPE', p.persontype) AS "Person Type"
                ,prod.name AS "Subscription Name"
                ,s.start_date AS "Subscription Start Date"
                ,s.end_date AS "Subscription End Date"
                ,prodold.name AS "Last Subscription Name"
                ,sold.center||'ss'||sold.id AS "Last Subscription ID Number"
                ,sold.start_date AS "Last Subscription Start Date"
                ,sold.end_date AS "Last Subscription End Date"
                ,pgl.product_group_id
        FROM
                subscriptions s
        JOIN
                centers c
                ON c.id = s.center
        JOIN
                persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
        JOIN
                subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.ID = s.subscriptiontype_id
                AND st.st_type != 2
        JOIN
                products prod
                ON prod.center = st.center
                AND prod.id = st.id
        LEFT JOIN
                product_and_product_group_link pgl
                ON pgl.product_center = prod.center
                AND pgl.product_id = prod.id
                AND pgl.product_group_id IN (237,2801,2606)                                        
        LEFT JOIN
                (SELECT
                        max(s.id) AS MaxID
                        ,s.center
                        ,s.owner_center
                        ,s.owner_id
                FROM
                        subscriptions s
                JOIN
                        subscriptiontypes st
                        ON st.center = s.subscriptiontype_center
                        AND st.ID = s.subscriptiontype_id
                        AND st.st_type != 2                
                WHERE 
                        s.center IN (:Scope)--Scope
                        AND
                        s.center||'ss'||s.id NOT IN 
                                                (SELECT s.center||'ss'||s.id 
                                                FROM subscriptions s
                                                JOIN subscriptiontypes st ON st.center = s.subscriptiontype_center AND st.ID = s.subscriptiontype_id AND st.st_type != 2
                                                JOIN params ON params.CENTER_ID = s.center 
                                                WHERE 
                                                        s.CREATION_TIME BETWEEN params.FromDate AND params.ToDate --Date
                                                        AND
                                                        s.center IN (:Scope)--Scope
                                                        AND
                                                        s.sub_state != 7
                                                        AND
                                                        (s.end_date > :ToDate OR s.end_date IS NULL)--Date
                                                )
                GROUP BY
                        s.center
                        ,s.owner_center
                        ,s.owner_id                                        
                )sprevious
                        ON sprevious.owner_center = s.owner_center
                        AND sprevious.owner_id = s.owner_id
        LEFT JOIN
                subscriptions sold
                ON sold.center =  sprevious.center
                AND sold.id =  sprevious.MaxID
        LEFT JOIN
                subscriptiontypes stold
                ON stold.center = sold.subscriptiontype_center
                AND stold.ID = sold.subscriptiontype_id
        LEFT JOIN
                products prodold
                ON prodold.center = stold.center
                AND prodold.id = stold.id                                        
        JOIN 
                params 
                ON params.CENTER_ID = s.center                                                                                                                                                                                
        WHERE 
                s.CREATION_TIME BETWEEN params.FromDate AND params.ToDate --Date
                AND
                s.center IN (:Scope)--Scope
                AND
                s.sub_state != 7
                AND
                (s.end_date > :ToDate OR s.end_date IS NULL) --Date 
        )t1
WHERE 
        t1.product_group_id IS NULL
                        

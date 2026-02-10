-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-4469
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT
        t1."Club Name"
        ,sum(t1."OPEN") AS "OPEN"
        ,sum(t1."UNASSIGNED") AS "UNASSIGNED"
        ,sum(t1."PENDING") AS "PENDING" 
        ,sum(t1."OVERDUE") AS "OVERDUE"
        ,sum(t1."ON_HOLD") AS "ON_HOLD"
        ,sum(t1."CLOSED") AS "CLOSED"
        ,sum(t1."DELETED") AS "DELETED"        
FROM
        (          
        Select 
                p.center||'p'||p.id
                ,t.id
                ,c.shortname AS "Club Name"
                ,CASE
                        WHEN t2.status = 'OPEN' THEN 1
                        ELSE 0
                END AS "OPEN"
                ,CASE
                        WHEN t2.status = 'UNASSIGNED' THEN 1
                        ELSE 0
                END AS "UNASSIGNED"
                ,CASE
                        WHEN t2.status = 'PENDING' THEN 1
                        ELSE 0
                END AS "PENDING"
                ,CASE
                        WHEN t2.status = 'OVERDUE' THEN 1
                        ELSE 0
                END AS "OVERDUE"
                ,CASE
                        WHEN t2.status = 'ON_HOLD' THEN 1
                        ELSE 0
                END AS "ON_HOLD" 
                ,CASE
                        WHEN t2.status = 'CLOSED' THEN 1
                        ELSE 0
                END AS "CLOSED" 
                ,CASE
                        WHEN t2.status = 'DELETED' THEN 1
                        ELSE 0
                END AS "DELETED"               
        FROM 
                Persons p
        JOIN    
                params 
                ON params.CENTER_ID = p.center        
        JOIN 
                centers c
                on c.id = p.center
        JOIN
                (SELECT 
                        max(t.id) AS ID
                        ,t.person_center
                        ,t.person_id
                FROM 
                        tasks t
                WHERE 
                        t.center in (:scope)
                GROUP BY
                        t.person_center
                        ,t.person_id
                )t
                        ON t.person_center = p.center
                        AND t.person_id = p.id         
        LEFT JOIN
                tasks t2
                ON t2.person_center = t.person_center 
                AND t2.person_id = t.person_id
                AND t2.id = t.ID
        
        WHERE
                t2.status in ('OPEN','UNASSIGNED','PENDING', 'OVERDUE', 'ON HOLD', 'CLOSED', 'DELETED')
                and p.center in (:scope)
                and t2.creation_time BETWEEN params.FromDate AND params.ToDate
                and t2.type_id = 400
        )t1
GROUP BY 
        t1."Club Name"
ORDER BY 1 
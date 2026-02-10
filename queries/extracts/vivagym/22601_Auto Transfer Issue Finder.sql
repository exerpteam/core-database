-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    transferee AS materialized (
---auto transfer sql---
SELECT
        t1.center,
        t1.id,
--        t1."PERSONKEY",
--        t1.externalid,
        t1.tocenterid        
FROM
(
        SELECT
            DISTINCT
                p.center,
                p.id,
                p.center || 'p' || p.id AS "PERSONKEY", 
                p.external_id AS externalid,
                s.center AS tocenterid
        FROM
            vivagym.persons p
        JOIN centers c 
                ON p.center = c.id 
                AND c.country = 'ES'
        JOIN
            vivagym.subscriptions s
        ON
            p.center = s.owner_center
        AND p.id = s.owner_id
        WHERE
            p.center != s.center
            AND s.state IN (2,4,8)
            AND p.center NOT IN (100)
            AND p.status NOT IN (4,5,7,8)
         ---   AND p.center IN (:center)
            AND NOT EXISTS 
            (
                SELECT
                        1
                FROM vivagym.subscriptions s2
                WHERE
                        p.center = s2.owner_center 
                        AND p.id = s2.owner_id
                        AND s2.center != s.center
                        AND (s2.center, s2.id) NOT IN ((s.center,s.id))
                        AND s2.state IN (2,4,8)
            )
            AND NOT EXISTS
            (
                SELECT
                        1
                FROM vivagym.subscriptions s3
                WHERE
                        s3.owner_center = s.owner_center
                        AND s3.owner_id = s.owner_id
                        AND s3.state IN (8)                
            )
) t1
        )         
          
          select 
                p.center||'p'||p.id as person_key,
                p.external_id,
                t.tocenterid,
                
                case when cast(floor(months_between(now(), p.BIRTHDATE) / 12) as int) > 150 then p.birthdate else null end as birthdate_issue,

                case when ccc.center is not null then 'open cash collection case' else null end as cash_collection_issue,
                
                case when c.startupdate > current_date then c.startupdate else null end as center_start_issue,
                    
                case when prt.blocked is true then prt.name else null end as clipcard_issue  

          from persons p          
          join transferee t on t.center = p.center and  p.id = t.id  
          join centers c on c.id = t.tocenterid         
          
          left join cashcollectioncases ccc on ccc.personcenter = p.center and ccc.personid = p.id
                and ccc.closed = false and ccc.missingpayment = true
         
          left join clipcards cc on p.center = cc.owner_center and p.id = cc.owner_id 
                and cc.finished is false and cc.cancelled is false and cc.blocked is false
          left join products pr on cc.center = pr.center and cc.id = pr.id
          left join products prt on pr.globalid = prt.globalid and prt.center = t.tocenterid and prt.blocked is true
          
          where 
                p.status not in (4, 5, 7, 8)


--        and p.external_id = '103117597'
          
          order by 4, 5, 6, 7 asc
          ;
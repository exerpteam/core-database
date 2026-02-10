-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                CAST(datetolongC(TO_CHAR((TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 month'), 'YYYY-MM-DD HH24:MI'), c.id) AS BIGINT) AS from_date,
                CAST(datetolongC(TO_CHAR((TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')),'YYYY-MM-DD HH24:MI'), c.id)-1 AS BIGINT) AS to_date,
                extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                c.id AS centerId,
                c.name AS center_name
        FROM centers c
        WHERE
                c.country = 'NO'
),
attr_change AS MATERIALIZED
(
        SELECT
                t1.current_person_center,
                t1.current_person_id,
                t1.new_value,
                t1.entry_time,
                t1.center_name
        FROM
        (
                SELECT
                        p.current_person_center,
                        p.current_person_id,
                        pcl.change_attribute,
                        pcl.new_value,
                        pcl.entry_time,
                        params.center_name,
                        rank() over (partition by p.current_person_center, p.current_person_id ORDER BY pcl.entry_time DESC) ranking
                FROM persons p
                JOIN params
                        ON p.center = params.centerId 
                JOIN person_change_logs pcl
                        ON pcl.person_center = p.center AND pcl.person_id = p.id
                WHERE
                    pcl.entry_time BETWEEN params.from_date and params.to_date
                    AND pcl.change_source NOT IN ('MEMBER_TRANSFER')
                    AND params.executionDate = 27
                    AND pcl.change_attribute = 'retentionoffer'
        ) t1
        WHERE t1.ranking = 1
        
)
SELECT
        ac.current_person_center||'p'||ac.current_person_id as "Person ID",
        s.center||'ss'||s.id as "Subscription ID",
        ac.center_name as "Center",
        TO_CHAR(longtodateC(ac.entry_time ,ac.current_person_center),'YYYY-MM-DD HH24:MI') as "Last Updated Time",
        ac.new_value "Extened Attribute Value",
        s.end_date as "Subscription End Date"
FROM attr_change ac
LEFT JOIN subscriptions s 
        ON ac.current_person_center = s.owner_center AND ac.current_person_id = s.owner_id
WHERE
        s.state IN (2,4)

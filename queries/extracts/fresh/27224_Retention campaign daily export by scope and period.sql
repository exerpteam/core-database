-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
            c.id               AS centerId,
            c.name             AS center_name
        FROM
            centers c
        WHERE
            c.country = 'NO' and c.id in (:scope)
    )
    ,
    attr_change AS MATERIALIZED
    (
        SELECT
            t1.current_person_center,
            t1.current_person_id,
			t1.change_attribute,
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
                    rank() over (partition BY p.current_person_center, p.current_person_id ORDER BY
                    pcl.entry_time DESC) ranking
                FROM
                    persons p
                JOIN
                    params
                ON
                    p.center = params.centerId
                JOIN
                    person_change_logs pcl
                ON
                    pcl.person_center = p.center
                AND pcl.person_id = p.id
                WHERE
                    pcl.entry_time BETWEEN params.fromDateLong AND params.toDateLong
                AND pcl.change_source NOT IN ('MEMBER_TRANSFER')
                and pcl.person_center = params.centerid
                AND pcl.change_attribute IN ('retentionoffer','retentionoffer2','retentionoffer3') ) t1
        WHERE
            t1.ranking = 1
    )
SELECT
    ac.current_person_center||'p'||ac.current_person_id                              AS "Person ID",
    s.center||'ss'||s.id                                                       AS "Subscription ID",
    ac.center_name                                                                     AS "Center",
    TO_CHAR(longtodateC(ac.entry_time ,ac.current_person_center),'YYYY-MM-DD HH24:MI') AS
    "Last Updated Time",
ac.change_attribute "Extened Attribute Name",
    ac.new_value "Extened Attribute Value",
    s.end_date AS "Subscription End Date"
FROM
    attr_change ac
LEFT JOIN
    subscriptions s
ON
    ac.current_person_center = s.owner_center
AND ac.current_person_id = s.owner_id
WHERE
    s.state IN (2,4)
AND ac.new_value != 'false'
-- The extract is extracted from Exerp on 2026-02-08
-- Created by Exerp (EC-7896) to find a true number of OJ's made
SELECT
        t1.*,
        ss.sales_date,
        TO_CHAR(longtodatec(s.creation_time, s.center),'HH24:MI') AS sub_creation_time
FROM
(
        WITH
            params AS MATERIALIZED
            (
                SELECT
                    datetolongc(TO_CHAR(TO_DATE(:fromdate , 'YYYY-MM-dd'), 'YYYY-MM-dd'),c.id) AS
                    from_date,
                    datetolongc(TO_CHAR(TO_DATE(:todate , 'YYYY-MM-dd') + interval '1 days', 'YYYY-MM-dd'),c.id)-1 AS
                            to_date,
                    c.id AS center_id
                FROM
                    centers c
                WHERE
                    c.country = 'GB'
                AND c.id NOT IN (999)
                AND c.id IN (:scope)
            )
        SELECT
            p.center||'p'||p.id                       AS memberId,
            p.center,
            p.id,
            DATE_TRUNC('DAY',longtodatec(scl.entry_start_time, scl.center)) AS entryDate,
            scl.employee_center||'emp'||scl.employee_id   AS employeeId
            
        FROM
            persons p
        JOIN
            params par
        ON
            p.center = par.center_id
        JOIN
            state_change_log scl
        ON
            p.center = scl.center
        AND p.id = scl.id
        AND scl.ENTRY_TYPE = 1 --person state change
        AND scl.stateid = 1
        WHERE
                scl.employee_center = 4
        AND scl.employee_id = 13601
        AND scl.entry_start_time >= par.from_date
        AND scl.entry_start_time <= par.to_date
) t1
JOIN subscription_sales ss
        ON ss.owner_center = t1.center AND ss.owner_id = t1.id
JOIN virginactive.subscriptions s 
        ON ss.subscription_center = s.center AND ss.subscription_id = s.id
WHERE
        ss.start_date = t1.entryDate
        AND (s.end_date IS NULL OR s.start_date <= s.end_date)
		
ORDER BY 
	sub_creation_time desc
WITH v_main AS
(
        SELECT
                p2.center,
                p2.id,
                p2.persontype,
                p2.status,
                pr.name AS prod_name,
                s2.center || 'ss' || s2.id AS subid,
                CASE s2.state WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS sub_state,
                CASE s2.sub_state WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 
                        THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS sub_substate,
                s2.start_date,
                s2.billed_until_date,
                s2.end_date
        FROM
        (
                SELECT
                        p.center,
                        p.id,
                        count(*) AS total_sub
                FROM puregym_switzerland.persons p
                JOIN puregym_switzerland.subscriptions s
                        ON p.center = s.owner_center AND p.id = s.owner_id
                WHERE
                        s.state IN (2,4)
                GROUP BY
                        p.center,
                        p.id
                HAVING count(*) > 1
        ) t1
        JOIN puregym_switzerland.persons p2 
                ON p2.center = t1.center AND p2.id = t1.id
        JOIN puregym_switzerland.subscriptions s2
                ON s2.owner_center = p2.center AND s2.owner_id = p2.id AND s2.state IN (2,4)
        JOIN puregym_switzerland.products pr
                ON pr.center = s2.subscriptiontype_center AND pr.id = s2.subscriptiontype_id
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(prod_name,1) OVER (PARTITION BY center,id ORDER BY subid) AS prod_name2,
                LEAD(sub_state,1) OVER (PARTITION BY center,id ORDER BY subid) AS sub_state2,
                LEAD(sub_substate,1) OVER (PARTITION BY center,id ORDER BY subid) AS sub_substate2,
                LEAD(start_date,1) OVER (PARTITION BY center,id ORDER BY subid) AS start_date2,
                LEAD(billed_until_date,1) OVER (PARTITION BY center,id ORDER BY subid) AS billed_until_date2,
                LEAD(end_date,1) OVER (PARTITION BY center,id ORDER BY subid) AS end_date2,
                
                LEAD(prod_name,2) OVER (PARTITION BY center,id ORDER BY subid) AS prod_name3,
                LEAD(sub_state,2) OVER (PARTITION BY center,id ORDER BY subid) AS sub_state3,
                LEAD(sub_substate,2) OVER (PARTITION BY center,id ORDER BY subid) AS sub_substate3,
                LEAD(start_date,2) OVER (PARTITION BY center,id ORDER BY subid) AS start_date3,
                LEAD(billed_until_date,2) OVER (PARTITION BY center,id ORDER BY subid) AS billed_until_date3,
                LEAD(end_date,2) OVER (PARTITION BY center,id ORDER BY subid) AS end_date3,
                
                LEAD(prod_name,3) OVER (PARTITION BY center,id ORDER BY subid) AS prod_name4,
                LEAD(sub_state,3) OVER (PARTITION BY center,id ORDER BY subid) AS sub_state4,
                LEAD(sub_substate,3) OVER (PARTITION BY center,id ORDER BY subid) AS sub_substate4,
                LEAD(start_date,3) OVER (PARTITION BY center,id ORDER BY subid) AS start_date4,
                LEAD(billed_until_date,3) OVER (PARTITION BY center,id ORDER BY subid) AS billed_until_date4,
                LEAD(end_date,3) OVER (PARTITION BY center,id ORDER BY subid) AS end_date4,
                
                ROW_NUMBER() OVER (PARTITION BY center,id ORDER BY subid) AS ADDONSEQ
        FROM v_main
)
SELECT 
        center || 'p' || id AS personid,
        CASE persontype WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' 
                        WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        CASE status WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 
                        THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        prod_name AS prod_name1,
        sub_state || '-' || sub_substate AS subscription_state1,
        start_date,
        billed_until_date,
        end_date,
        
        prod_name2,
        sub_state2 || '-' || sub_substate2 AS subscription_state2,
        start_date2,
        billed_until_date2,
        end_date2,
        
        prod_name3,
        sub_state3 || '-' || sub_substate3 AS subscription_state3,
        start_date3,
        billed_until_date3,
        end_date3,
        
        prod_name4,
        sub_state4 || '-' || sub_substate4 AS subscription_state4,
        start_date4,
        billed_until_date4,
        end_date4         
FROM v_pivot
WHERE ADDONSEQ = 1
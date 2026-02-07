WITH v_main AS
(
        SELECT
                t1.center,
                t1.id,
                t1.persontype,
                pr.name AS prod_name,
                s2.center || 'ss' || s2.id AS subid,
                CASE s2.state WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS sub_state,
                CASE s2.sub_state WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 
                        THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS sub_substate,
                s2.start_date,
                s2.billed_until_date,
                s2.end_date,
                mpr.cached_productname AS addon_name,
                sa2.start_date AS addon_startdate,
                sa2.id as addon_id,
                sa2.end_date AS addon_enddate,
                sa2.use_individual_price AS addon_use_individual_price,
                sa2.individual_price_per_unit AS addon_price
        FROM
        (
                WITH params AS MATERIALIZED
                (
                        SELECT
                                to_date(getCenterTime(c.id),'YYYY-MM-DD') AS todaysdate,
                                c.id
                        FROM centers c
                )
                SELECT
                        p.center,
                        p.id,
                        p.persontype,
                        s.center AS scenter,
                        s.id AS sid,
                        par.todaysdate,
                        count(*) AS total_sub
                FROM puregym_switzerland.persons p
                JOIN params par ON par.id = p.center
                JOIN puregym_switzerland.subscriptions s
                        ON p.center = s.owner_center AND p.id = s.owner_id
                JOIN puregym_switzerland.subscription_addon sa
                        ON s.center = sa.subscription_center AND s.id = sa.subscription_id AND sa.cancelled = false 
                                AND sa.start_date <= par.todaysdate
                                AND (sa.end_date IS NULL OR sa.end_date >= par.todaysdate)
                WHERE
                        s.state IN (2,4)
                GROUP BY
                        p.center,
                        p.id,
                        p.persontype,
                        s.center,
                        s.id,
                        par.todaysdate
                HAVING count(*) > 1
        ) t1
        JOIN puregym_switzerland.subscriptions s2
                ON s2.center = t1.scenter AND s2.id = t1.sid
        JOIN puregym_switzerland.products pr
                ON pr.center = s2.subscriptiontype_center AND pr.id = s2.subscriptiontype_id
        JOIN puregym_switzerland.subscription_addon sa2
                ON s2.center = sa2.subscription_center AND s2.id = sa2.subscription_id AND sa2.cancelled = false 
                        AND sa2.start_date <= t1.todaysdate
                        AND (sa2.end_date IS NULL OR sa2.end_date >= t1.todaysdate)
        JOIN puregym_switzerland.masterproductregister mpr
                ON sa2.addon_product_id = mpr.id
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(addon_name,1) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name2,
                LEAD(addon_startdate,1) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate2,
                LEAD(addon_enddate,1) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate2,
                LEAD(addon_use_individual_price,1) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price2,
                LEAD(addon_price,1) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price2,
                
                LEAD(addon_name,2) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name3,
                LEAD(addon_startdate,2) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate3,
                LEAD(addon_enddate,2) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate3,
                LEAD(addon_use_individual_price,2) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price3,
                LEAD(addon_price,2) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price3,
                
                LEAD(addon_name,3) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name4,
                LEAD(addon_startdate,3) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate4,
                LEAD(addon_enddate,3) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate4,
                LEAD(addon_use_individual_price,3) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price4,
                LEAD(addon_price,3) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price4,
                
                LEAD(addon_name,4) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name5,
                LEAD(addon_startdate,4) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate5,
                LEAD(addon_enddate,4) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate5,
                LEAD(addon_use_individual_price,4) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price5,
                LEAD(addon_price,4) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price5,
                
                LEAD(addon_name,5) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name6,
                LEAD(addon_startdate,5) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate6,
                LEAD(addon_enddate,5) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate6,
                LEAD(addon_use_individual_price,5) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price6,
                LEAD(addon_price,5) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price6,
                
                LEAD(addon_name,6) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name7,
                LEAD(addon_startdate,6) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate7,
                LEAD(addon_enddate,6) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate7,
                LEAD(addon_use_individual_price,6) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price7,
                LEAD(addon_price,6) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price7,
                
                LEAD(addon_name,7) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name8,
                LEAD(addon_startdate,7) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate8,
                LEAD(addon_enddate,7) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate8,
                LEAD(addon_use_individual_price,7) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price8,
                LEAD(addon_price,7) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price8,
                
                LEAD(addon_name,8) OVER (PARTITION BY center,id,subid ORDER BY addon_id) AS addon_name9,
                LEAD(addon_startdate,8) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_startdate9,
                LEAD(addon_enddate,8) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_enddate9,
                LEAD(addon_use_individual_price,8) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_use_individual_price9,
                LEAD(addon_price,8) OVER (PARTITION BY center,id,subid ORDER BY subid) AS addon_price9,
                
                ROW_NUMBER() OVER (PARTITION BY center,id,subid ORDER BY subid) AS ADDONSEQ
        FROM v_main
)
SELECT 
        center || 'p' || id AS personid,
        CASE persontype WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' 
                        WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        prod_name AS subcription_name,
        sub_state || '-' || sub_substate AS subscription_state,
        start_date,
        billed_until_date,
        end_date,
        
        addon_name,
        addon_startdate,
        addon_enddate,
        addon_use_individual_price,
        addon_price,
        
        addon_name2,
        addon_startdate2,
        addon_enddate2,
        addon_use_individual_price2,
        addon_price2,
     
        addon_name3,
        addon_startdate3,
        addon_enddate3,
        addon_use_individual_price3,
        addon_price3,
        
        addon_name4,
        addon_startdate4,
        addon_enddate4,
        addon_use_individual_price4,
        addon_price4,
        
        addon_name5,
        addon_startdate5,
        addon_enddate5,
        addon_use_individual_price5,
        addon_price5,
        
        addon_name6,
        addon_startdate6,
        addon_enddate6,
        addon_use_individual_price6,
        addon_price6,
        
        addon_name7,
        addon_startdate7,
        addon_enddate7,
        addon_use_individual_price7,
        addon_price7,
        
        addon_name8,
        addon_startdate8,
        addon_enddate8,
        addon_use_individual_price8,
        addon_price8,
        
        addon_name9,
        addon_startdate9,
        addon_enddate9,
        addon_use_individual_price9,
        addon_price9
FROM v_pivot
WHERE ADDONSEQ = 1
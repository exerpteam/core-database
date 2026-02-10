-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED (
    SELECT 
        TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS cutdate,
        c.id AS center_id
    FROM centers c
)
SELECT
	ce.shortname "Club Name",
	p.center||'p'||p.id "Member ID", 
    pr.name "Subscription Name",
    s.start_date "Subscription Start Date",
    s.end_date "Subscription End Date",
    s.binding_end_date "Contract End Date",
    --prg.name AS product_group_name,
    p.firstname "First Name"
FROM persons p
JOIN subscriptions s 
    ON s.owner_center = p.center 
   AND s.owner_id = p.id
JOIN params par 
    ON par.center_id = s.center
JOIN subscriptiontypes st 
    ON st.center = s.subscriptiontype_center 
   AND st.id = s.subscriptiontype_id
JOIN products pr 
    ON pr.center = st.center 
   AND pr.id = st.id
JOIN product_and_product_group_link prgl 
    ON prgl.product_center = pr.center 
   AND prgl.product_id = pr.id
JOIN product_group prg 
    ON prg.id = prgl.product_group_id
JOIN CENTERS ce
	on p.center = ce.id
WHERE 
    prg.name LIKE '%PT by DD%'  -- has active PT sub
    AND (s.end_date IS NULL OR s.end_date >= par.cutdate)
    AND NOT EXISTS (
        SELECT 1
        FROM subscriptions s2
        JOIN subscriptiontypes st2 
            ON st2.center = s2.subscriptiontype_center 
           AND st2.id = s2.subscriptiontype_id
        JOIN products pr2 
            ON pr2.center = st2.center 
           AND pr2.id = st2.id
        JOIN product_and_product_group_link prgl2 
            ON prgl2.product_center = pr2.center 
           AND prgl2.product_id = pr2.id
        JOIN product_group prg2 
            ON prg2.id = prgl2.product_group_id
        WHERE 
            s2.owner_center = p.center
            AND s2.owner_id = p.id
            AND prg2.name LIKE 'Mem Cat:%'
            AND (s2.end_date IS NULL OR s2.end_date >= par.cutdate)
            AND s2.state IN ('4', '2', '8')  -- exclude if active or frozen or created
    )
	AND p.center in (:center)
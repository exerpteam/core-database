-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(       
        SELECT
                t1.center,
                extract(MONTH FROM TO_DATE(GETCENTERTIME(t1.center), 'YYYY-MM-DD HH24:MI')) AS mdate,
                extract(DAY FROM TO_DATE(GETCENTERTIME(t1.center), 'YYYY-MM-DD HH24:MI')) AS edate,
                dateToLongC(TO_CHAR(DATE_TRUNC('day',TO_DATE(getCenterTime(t1.center), 'YYYY-MM-DD')), 'YYYY-MM-DD'),t1.center) as cutdate
        FROM
        (
                WITH RECURSIVE find_centers AS
                (
                        SELECT
                                ac.center
                        FROM vivagym.areas a
                        JOIN vivagym.area_centers ac ON a.id = ac.area
                        WHERE
                                a.id = 14
                        UNION 
                        SELECT
                                ac.center
                        FROM vivagym.areas a
                        JOIN vivagym.areas a2 ON a2.parent = a.id
                        JOIN vivagym.area_centers ac ON a2.id = ac.area
                        WHERE
                                a.id = 14
                )
                SELECT * FROM find_centers
        ) t1
)
SELECT
        c.name AS center_name,
        c.id AS center_id,
        p.center || 'p' || p.id AS personid,
        (CASE p.persontype 
                        WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' 
                        WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' 
                        WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' 
        END) AS person_type,
        (CASE p.status 
                        WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' 
                        WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' 
        END) AS person_status,
        p.external_id,
        s.center || 'ss' || s.id AS subscription_id,
        longtodatec(s.creation_time, s.center) AS subscription_creation_date,
        s.start_date, 
        s.billed_until_date,
        s.end_date,
        s.subscription_price,
        (CASE s.state 
                        WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' 
                        ELSE 'Undefined' 
        END) AS subscription_state,
        (CASE s.sub_state 
                         WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' 
                         WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' 
                         WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' 
        END) AS subscription_sub_state,        
        pr.name,
        pr.globalid,
        s2t.center || 'ss' || s2t.id AS transferred_sub,
        s2c.center || 'ss' || s2c.id AS change_sub,
        r.center || 'p' || r.id Careful_Has_Payer
FROM vivagym.persons p
JOIN params par ON p.center = par.center
JOIN vivagym.centers c ON par.center = c.id
JOIN vivagym.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN vivagym.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN vivagym.products pr ON st.center = pr.center AND st.id = pr.id
LEFT JOIN vivagym.subscriptions s2t ON s2t.transferred_center = s.center AND s2t.transferred_id = s.id
LEFT JOIN vivagym.subscriptions s2c ON s2c.changed_to_center = s.center AND s2c.changed_to_id = s.id
LEFT JOIN vivagym.relatives r ON p.center = r.relativecenter AND p.id = r.relativeid AND r.rtype = 12 AND r.status = 1
WHERE
        p.persontype NOT IN (2)
        AND p.status NOT IN (4,5,7,8)
        AND s.state IN (2,4)
		AND st.st_type NOT IN (0)
        AND NOT EXISTS
        (
                SELECT 1
                FROM vivagym.product_and_product_group_link ppl
                JOIN vivagym.product_group pg ON ppl.product_group_id = pg.id
                WHERE
                        ppl.product_center = pr.center
                        AND ppl.product_id = pr.id
                        AND pg.id IN (12,602,202,8801)
        )
		-- NOT NEEDED, TARGET GROUP WILL SELL IT FOR FREE INSTEAD
        --AND
        --AND
        --(
        --        s.creation_time < par.cutdate
        --        OR 
        --        s2t.center IS NOT NULL
        --        OR
        --        s2c.center IS NOT NULL
        --)
ORDER BY 1, 8 DESC

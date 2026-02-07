SELECT
        p.center||'p'||p.id as "Person ID"
        ,pea.txtvalue
        ,CASE
                WHEN s.state = 2 THEN 'Active'
                WHEN s.state = 3 THEN 'Ended'
                WHEN s.state = 4 THEN 'Frozen'
                WHEN s.state = 7 THEN 'Window'
                WHEN s.state = 8 THEN 'Created'
                ELSE 'Unknown'
        END AS "Subscription State"
        ,sp.price
        ,sp.coment                
        ,sp.from_date AS "Price Change From"
        ,sp.to_date AS "Price Change To"     
FROM 
        fernwood.persons p
JOIN
        fernwood.subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id
        AND s.state not in (3,5,6,9,10) 
JOIN 
        subscription_price sp 
        ON sp.subscription_center = s.center 
        AND sp.subscription_id = s.id
        AND sp.to_date >= current_date
LEFT JOIN
        fernwood.person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id 
        AND pea.name = '_eClub_OldSystemPersonId'
WHERE
	p.center IN (:Scope)   
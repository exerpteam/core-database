-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT *
FROM 
    fw.subscription_freeze_period sfp
left join 
	fw.subscriptions s 
	on     
		sfp.subscription_center = s.center 
	and sfp.subscription_id = s.id
where
    sfp.start_date >= :from_date AND
    sfp.start_date <= :to_date

-- The extract is extracted from Exerp on 2026-02-08
--  




SELECT 
   s.owner_center||'p'||s.owner_id as CustomerID, 
    fh.end_date 
FROM 
    fw.SUBSCRIPTION_FREEZE_PERIOD fh
left join fw.subscriptions s 
	on 
	fh.subscription_center  = s.center 
	and  fh.subscription_id  = s.id
where
    fh.end_date >= current_date + 9 AND
	fh.end_date <= current_date + 10
order by
    fh.end_date, s.owner_center||'p'||s.owner_id

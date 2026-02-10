-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	s.owner_center||'p'||s.owner_id as CustomerID, 
	fh.start_date,    
	fh.end_date,
	fh.type,
	fh.state
	 
FROM 
    fw.SUBSCRIPTION_FREEZE_PERIOD fh
left join fw.subscriptions s 
	on 
	fh.subscription_center  = s.center 
	and  fh.subscription_id  = s.id
where
   	s.owner_center||'p'||s.owner_id in (:person)
	AND fh.type = 'CONTRACTUAL'
--and FH.STATE <> 'CANCELLED'
-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT 
	p.center ||'p'|| p.id as person_id, 
	p.fullname,
	prod.name as subscription_name,
	CASE  p.persontype  
		WHEN 0 THEN 'Private'  
		WHEN 1 THEN 'Student'  
		WHEN 2 THEN 'Staff'  
		WHEN 3 THEN 'Friend'  
		WHEN 4 THEN 'Corporate'  
		WHEN 5 THEN 'Onemancorporate'  
		WHEN 6 THEN 'Family'  
		WHEN 7 THEN 'Senior'  
		WHEN 8 THEN 'Guest'  
		WHEN 9 THEN  'Child'  
	WHEN 10 THEN  'External_Staff' 
	ELSE 'Unknown' END AS person_type,
	s.start_date,
	s.end_date,
	p.last_active_start_date,
	p.last_active_end_date
 FROM  persons p
 JOIN SUBSCRIPTIONS S
	    ON s.OWNER_CENTER = p.CENTER
    	AND s.OWNER_ID = p.ID 
 JOIN PRODUCTS prod
 	 	ON prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     	AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 WHERE p.last_active_start_date <= ($$first_start_date$$)
 AND (p.last_active_end_date >= CURRENT_DATE OR p.last_active_end_date is null)
 AND p.center in ($$scope$$)
 AND prod.name in ('PT Ex GI 11 mesi Collection',
'PT Ex GI 11 mesi Life Metro',
'PT Ex GI 11 mesi Life Province',
'PT Ex GI 11 mesi Premium',
'PT Ex GI 11 mesi Premium Plus',
'PT Ex GI 12 mesi Collection',
'PT Ex GI 12 mesi Collection CASH',
'PT Ex GI 12 mesi Life Metro',
'PT Ex GI 12 mesi Life Metro CASH',
'PT Ex GI 12 mesi Life Province',
'PT Ex GI 12 mesi Life Province CASH',
'PT Ex GI 12 mesi Premium',
'PT Ex GI 12 mesi Premium CASH',
'PT Ex GI 12 mesi Premium Plus',
'PT Ex GI 12 mesi Premium Plus CASH',
'PT Ex GI Fee 11 Mesi ',
'PT Ex GI Fee 12 Mesi ',
'PT Ex GI Fee Reformer 11 Mesi ',
'PT Ex GI Fee Reformer 12 Mesi ',
'PT EX GI Nuovi Club ',
'PT EX GI Nuovi Club Cash',
'PT EX GI Operating Club ',
'PT EX GI Operating Club Cash',
'PT Fee 11 Mesi ',
'PT Fee 11 mesi Collection',
'PT Fee 11 mesi Life Metro',
'PT Fee 11 mesi Life Province',
'PT Fee 11 mesi Premium',
'PT Fee 11 mesi Premium Plus',
'PT Fee 12 Mesi ',
'PT Fee 12 Mesi Collection',
'PT Fee 12 mesi Collection CASH',
'PT Fee 12 mesi Life Metro',
'PT Fee 12 mesi Life Metro CASH',
'PT Fee 12 mesi Life Province',
'PT Fee 12 mesi Life Province CASH',
'PT Fee 12 mesi Premium',
'PT Fee 12 mesi Premium CASH',
'PT Fee 12 mesi Premium Plus',
'PT Fee 12 mesi Premium Plus CASH',
'PT Fee Cash',
'PT Fee Reformer 11 Mesi ',
'PT Fee Reformer 12 Mesi ',
'PT Fee Reformer Cash',
'PT Fee Revolution ',
'PT Fee WeekEnd +1 Collection',
'PT Fee WeekEnd +1 Collection CASH',
'PT Fee WeekEnd +1 Life Metro',
'PT Fee WeekEnd +1 Life Metro CASH',
'PT Fee WeekEnd +1 Life Province',
'PT Fee WeekEnd +1 Life Province CASH',
'PT Fee WeekEnd +1 Premium',
'PT Fee WeekEnd +1 Premium CASH',
'PT Fee WeekEnd +1 Premium Plus',
'PT Fee WeekEnd +1 Premium Plus CASH',
'PT Fee WeekEnd +6 Collection',
'PT Fee WeekEnd +6 Collection CASH',
'PT Fee WeekEnd +6 Life Metro',
'PT Fee WeekEnd +6 Life Metro CASH',
'PT Fee WeekEnd +6 Life Province',
'PT Fee WeekEnd +6 Life Province CASH',
'PT Fee WeekEnd +6 Premium',
'PT Fee WeekEnd +6 Premium CASH',
'PT Fee WeekEnd +6 Premium Plus',
'PT Fee WeekEnd +6 Premium Plus CASH',
'PT Nuovi Club ',
'PT Nuovi Club Cash',
'PT Operating Club',
'PT Operating Club Cash ',
'PT Week End Ex GI Fee 11 Mesi ',
'PT Week End Ex GI Fee 12 Mesi ',
'PT Week End Fee 11 Mesi ',
'PT Week End Fee 12 Mesi ',
'PT Week End Fee Cash',
'V-Trainer Legacy',
'V-Trainer Legacy Cash')
 ORDER BY p.center ||'p'|| p.id, s.start_date, s.end_date
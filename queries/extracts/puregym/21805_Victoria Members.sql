-- The extract is extracted from Exerp on 2026-02-08
--  
select s.subscription_center || 'ss' || s.subscription_id as ID from PUREGYM.SUBSCRIPTION_REDUCED_PERIOD s
where (s.SUBSCRIPTION_CENTER,s.SUBSCRIPTION_ID) IN (:subs) and s.TYPE ='FREE_ASSIGNMENT'
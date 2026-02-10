-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT * 
FROM subscriptions sub
Where sub.center in (:center)
LIMIT 500;


-- This is the version from 2026-02-05
--  
SELECT * 
FROM subscriptions sub
Where sub.center in (:center)
LIMIT 500;


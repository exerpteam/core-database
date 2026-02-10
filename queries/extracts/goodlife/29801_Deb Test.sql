-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT

 
*
 

FROM
 

subscriptions s
 

WHERE



s.state = 2
AND s.billed_until_date >= '01-01-2017'
AND s.billed_until_date <= '12-31-2017'
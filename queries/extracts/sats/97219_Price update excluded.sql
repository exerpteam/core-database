-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
s.owner_center ||'p' || s.owner_id as "Person ID",
s.center ||'ss' || s.id as "Subscription ID"
        
   FROM
        subscriptions s
  WHERE
      
            s.is_price_update_excluded = true
        AND s.state in ('2','4')
        AND s.center in (:scope)
        ;
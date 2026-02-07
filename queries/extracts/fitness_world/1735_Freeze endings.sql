-- This is the version from 2026-02-05
--  
SELECT 
    count(distinct(s.owner_center||'p'||s.owner_id)) as antal_ending, 
    fh.end_date 
FROM 
    fw.SUBSCRIPTION_FREEZE_PERIOD fh
left join fw.subscriptions s on fh.subscription_center = s.center and  fh.subscription_id = s.id
where
    fh.end_date >= :from_date AND
    fh.end_date <= :to_date 
group by 
    fh.end_date
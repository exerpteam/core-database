-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
'XXXX subs', subs.*, --subscription details
'XXXX srp', srp.* --subscription period details (Free Periods)

FROM subscription_reduced_period srp 
JOIN subscriptions subs ON subs.center = srp.subscription_center AND subs.id = srp.subscription_id

WHERE srp.state <> 'CANCELLED' 
AND srp.end_date >= '2021-01-20'
AND (srp.subscription_center = 74 AND srp.subscription_id = 99038 OR 
srp.subscription_center = 132 AND srp.subscription_id = 101412 OR 
srp.subscription_center = 132 AND srp.subscription_id = 103001 OR 
srp.subscription_center = 132 AND srp.subscription_id = 104407 OR 
srp.subscription_center = 132 AND srp.subscription_id = 107402 OR 
srp.subscription_center = 132 AND srp.subscription_id = 113603 OR 
srp.subscription_center = 132 AND srp.subscription_id = 113836 OR 
srp.subscription_center = 132 AND srp.subscription_id = 114015 OR 
srp.subscription_center = 132 AND srp.subscription_id = 117202 OR 
srp.subscription_center = 147 AND srp.subscription_id = 411 OR 
srp.subscription_center = 147 AND srp.subscription_id = 705 OR 
srp.subscription_center = 147 AND srp.subscription_id = 940 OR 
srp.subscription_center = 147 AND srp.subscription_id = 1866 OR 
srp.subscription_center = 147 AND srp.subscription_id = 3024 OR 
srp.subscription_center = 147 AND srp.subscription_id = 3328 OR 
srp.subscription_center = 147 AND srp.subscription_id = 13630 OR 
srp.subscription_center = 147 AND srp.subscription_id = 56415 OR 
srp.subscription_center = 147 AND srp.subscription_id = 57211 OR 
srp.subscription_center = 147 AND srp.subscription_id = 69439 OR 
srp.subscription_center = 147 AND srp.subscription_id = 102641 OR 
srp.subscription_center = 165 AND srp.subscription_id = 1555 OR 
srp.subscription_center = 165 AND srp.subscription_id = 2344 OR 
srp.subscription_center = 165 AND srp.subscription_id = 2378 OR 
srp.subscription_center = 165 AND srp.subscription_id = 2398 OR 
srp.subscription_center = 165 AND srp.subscription_id = 3075 OR 
srp.subscription_center = 165 AND srp.subscription_id = 3235 OR 
srp.subscription_center = 165 AND srp.subscription_id = 67456 OR 
srp.subscription_center = 165 AND srp.subscription_id = 68614 OR 
srp.subscription_center = 165 AND srp.subscription_id = 71013 OR 
srp.subscription_center = 165 AND srp.subscription_id = 108221 OR 
srp.subscription_center = 165 AND srp.subscription_id = 111409 OR 
srp.subscription_center = 202 AND srp.subscription_id = 96422 OR 
srp.subscription_center = 224 AND srp.subscription_id = 93402 OR 
srp.subscription_center = 224 AND srp.subscription_id = 97601 OR 
srp.subscription_center = 228 AND srp.subscription_id = 118232 OR 
srp.subscription_center = 237 AND srp.subscription_id = 113619 OR 
srp.subscription_center = 277 AND srp.subscription_id = 84201 OR 
srp.subscription_center = 285 AND srp.subscription_id = 110406 OR 
srp.subscription_center = 288 AND srp.subscription_id = 31508 OR 
srp.subscription_center = 288 AND srp.subscription_id = 74251 OR 
srp.subscription_center = 288 AND srp.subscription_id = 74267 OR 
srp.subscription_center = 288 AND srp.subscription_id = 77011 OR 
srp.subscription_center = 288 AND srp.subscription_id = 87047 OR 
srp.subscription_center = 288 AND srp.subscription_id = 94720 OR 
srp.subscription_center = 288 AND srp.subscription_id = 95876 OR 
srp.subscription_center = 288 AND srp.subscription_id = 113416 OR 
srp.subscription_center = 288 AND srp.subscription_id = 114034 OR 
srp.subscription_center = 303 AND srp.subscription_id = 99023 OR 
srp.subscription_center = 303 AND srp.subscription_id = 100812 OR 
srp.subscription_center = 306 AND srp.subscription_id = 99207 OR 
srp.subscription_center = 306 AND srp.subscription_id = 107058 OR 
srp.subscription_center = 306 AND srp.subscription_id = 109033 OR 
srp.subscription_center = 306 AND srp.subscription_id = 110406 OR 
srp.subscription_center = 306 AND srp.subscription_id = 110807 OR 
srp.subscription_center = 308 AND srp.subscription_id = 107440 OR 
srp.subscription_center = 315 AND srp.subscription_id = 66004 OR 
srp.subscription_center = 315 AND srp.subscription_id = 78814 OR 
srp.subscription_center = 315 AND srp.subscription_id = 102410 OR 
srp.subscription_center = 315 AND srp.subscription_id = 107407 OR 
srp.subscription_center = 317 AND srp.subscription_id = 88018 OR 
srp.subscription_center = 317 AND srp.subscription_id = 104428 OR 
srp.subscription_center = 318 AND srp.subscription_id = 711 OR 
srp.subscription_center = 318 AND srp.subscription_id = 743 OR 
srp.subscription_center = 318 AND srp.subscription_id = 19824 OR 
srp.subscription_center = 318 AND srp.subscription_id = 23823 OR 
srp.subscription_center = 318 AND srp.subscription_id = 38813 OR 
srp.subscription_center = 318 AND srp.subscription_id = 59040 OR 
srp.subscription_center = 318 AND srp.subscription_id = 85402 OR 
srp.subscription_center = 318 AND srp.subscription_id = 100402 OR 
srp.subscription_center = 319 AND srp.subscription_id = 100213)
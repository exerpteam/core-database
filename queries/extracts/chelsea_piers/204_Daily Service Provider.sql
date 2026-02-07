SELECT
    p.external_id as Service_provider_id,
    p.fullname as service_provider_name,
    ccu.*
FROM
    clipcards cc
JOIN
    chelseapiers.card_clip_usages ccu
ON
    ccu.card_center = cc.center
AND ccu.card_id = cc.id
AND ccu.card_subid = cc.subid
JOIN persons p on p.center = ccu.employee_center
and p.id = ccu.employee_id
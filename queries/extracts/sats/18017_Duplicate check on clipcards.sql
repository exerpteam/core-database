select
    c.owner_center||'p'||c.owner_id as customer,
    ccu.description,
    count(ccu.description) as count_des
from
    sats.card_clip_usages ccu
join sats.clipcards c
    on
    ccu.card_center = c.center
    and ccu.card_id = c.id
    and ccu.card_subid = c.subid
where
    ccu.description like ('Personal Training - %')
	and ccu.time between :fromdate and :todate
group by
    c.owner_center,
    c.owner_id,
    ccu.description
having count(*) > 1
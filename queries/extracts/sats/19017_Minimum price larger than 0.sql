Select
    pro.globalid,
    pro.name,
    pro.min_price
from
    products pro
where
    pro.min_price > 0
    and pro.blocked = 0
    and pro.ptype = 1
group by
    pro.globalid,
    pro.name,
    pro.min_price
order by
    pro.globalid
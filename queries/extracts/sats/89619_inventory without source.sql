select
t1.ref_center,
--t1.rnk,
t1.entrydate,
--t1.type,
t1.coment,
t1.balance_quantity,
t1.source_id

from
(
select
rank() over(partition by it.coment ORDER BY it.entry_time  DESC) as rnk,
longtodate(it.entry_time) as entrydate,
--longtodate(os.entry_time) as oldsoruce,
--os.coment,
*
from inventory_trans it

/*join inventory_trans os
on
os.id = it.first_source_id*/

where
it.ref_center in (:scope)
and it.entry_time between :datefrom and :dateto
--and it.source_id is null
--and it.coment = 'Hårsnoddar'
and it.type != 'DELIVERY'
--and it.product_id = 434
and not exists
(select
1
from inventory_trans os

where
os.type = 'DELIVERY'
and os.id = it.id 
and os.entry_time between :datefrom and :dateto) 

order by
rnk ) t1
where
t1.rnk = 1
and t1.source_id is null
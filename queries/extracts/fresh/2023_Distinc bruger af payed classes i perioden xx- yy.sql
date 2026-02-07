Select 
	i.PAYER_CENTER,
    i.PAYER_CENTER||'p'||i.PAYER_id
from
    invoices i
join
    invoicelines il
    on  i.id = il.id
join
    products p
    on il.productcenter = p.center
    and il.productid = p.id
where
    i.trans_time >= :purchase_from
    and i.trans_time <= :purchase_to +1 /*day not included*/
    and p.globalid = 'PAY_FOR_CLASS_USAGE'
group by
	i.PAYER_CENTER
order by
    i.PAYER_CENTER
select
     p.center||'p'||p.id 
from
     persons p
join subscriptions s
    on
     p.center = s.owner_center
     and p.id = s.owner_id
join subscriptiontypes st
    on
    s.subscriptiontype_center = st.center
    and s.subscriptiontype_id = st.id
join products prod
    on
    st.center = prod.center
    and st.id = prod.id
where
    prod.globalid in ('EFT_BLACK_LABEL',
'CASH_12MONTHS_BLACK_LABEL','EFT_BLACK_LABEL_GUEST')
and s.start_date <= :end_date 
and (  s.end_date >= :start_date  OR s.end_date is null  )
and p.center in (:scope)

Intersect

select
     i2.person_center||'p'||i2.person_id
from
     invoices i2
join invoicelines il2
     on i2.id = il2.id
join products p2
     on il2.productcenter = p2.center
     and il2.productid = p2.id
where
     longtodate(i2.trans_time) >= :start_date 
     and longtodate(i2.trans_time) <= :end_date
     and p2.globalid like 'PAY_FOR_CLASS_USAGE'
	 and i2.person_center in (:scope)
-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct
 t1.product_center,
 pr.name,
                t1.product_id,
               longtodate(mpr.last_state_change),
                t1.balance_quantity
 
 from
 (
 
 SELECT
                rank() over(partition by i.id, it.product_center, it.product_id ORDER BY it.entry_time DESC) as rnk,
                i.id,
                i.state,
                it.type,
                it.coment, 
                it.product_center,
                it.product_id,
                longtodatec(it.entry_time, it.product_center) as entry_time,
                it.balance_quantity,
                it.balance_value,
                it.quantity,
                it.employee_center,
                it.employee_id
                
        FROM sats.inventory i
      JOIN sats.centers c ON i.center = c.id AND c.country in ('DK','FI','NO','SE')
        JOIN sats.inventory_trans it ON it.inventory = i.id
        WHERE 
                i.state = 'OPEN'
               )t1
     

join products pr
on
t1.product_center = pr.center
and
t1.product_id = pr.id 
join MASTERPRODUCTREGISTER mpr
on
pr.globalid = mpr.globalid

where
rnk = 1    
and mpr.state IN ('INACTIVE')   
and t1.balance_quantity != 0  
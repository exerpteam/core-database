select 
    per.external_id,
    per.center||'p'||per.id                            as "member id",
    prod2.name                                         as "subscription_name",
    sa.subscription_center ||'ss'|| sa.subscription_id as "subscription key",
    s.center                                           as subscription_center,
    sa.id                                              as "subscription add-on key",
    prod.name                                          as add_on_name,
    prod.globalid                                      as globalid,
    sa.center_id                                       as add_on_scope,
    sa.addon_product_id                                as addon_product_id,
    sa.start_date                                      as start_date,
    sa.end_date                                        as end_date,
    sa.individual_price_per_unit                       as individual_price_per_unit
    
from subscription_addon sa
join subscriptions s on sa.subscription_center = s.center and sa.subscription_id = s.id
join persons per on per.center = s.owner_center and per.id = s.owner_id
join masterproductregister m on m.id = sa.addon_product_id
join products prod on prod.center = sa.center_id and prod.globalid = m.globalid
join subscriptiontypes st on s.subscriptiontype_center = st.center and s.subscriptiontype_id = st.id
join products prod2 on st.center = prod2.center and st.id = prod2.id

where
        sa.cancelled = 0
        and per.center in (:scope)
        and s.state in (2,4,8)
        and ((sa.end_date is null) or (sa.end_date > current_timestamp))
        and sa.start_date > current_timestamp
SELECT

ps.name AS Privilege_Set_Name
,m.cached_productname AS Product_Name
,m.globalid
,pp.price_modification_name
,pp.price_modification_amount
,pp.price_modification_rounding
,pp.disable_min_price
,pp.purchase_right

FROM

product_privileges pp

JOIN masterproductregister m
ON pp.ref_globalid = m.globalid

JOIN privilege_sets ps
ON ps.id = pp.privilege_set

ORDER BY ps.name
,cached_productname
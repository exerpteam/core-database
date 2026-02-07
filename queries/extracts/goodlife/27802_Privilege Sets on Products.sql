SELECT

m.cached_productname AS Product_Name
,m.globalid
,ps.name
,pp.name AS Sanction


FROM

masterproductregister m

JOIN privilege_grants pg
ON pg.granter_id = m.id
AND pg.granter_service = 'GlobalSubscription'
AND (pg.valid_to > (CAST((CURRENT_DATE-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT))*24*3600*1000
OR pg.valid_to IS NULL
)

JOIN privilege_sets ps
ON ps.id = pg.privilege_set

LEFT JOIN privilege_punishments pp
ON pg.punishment = pp.id


ORDER BY m.cached_productname
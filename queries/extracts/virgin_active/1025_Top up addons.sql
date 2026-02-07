SELECT
           p.CENTER,
           p.ID,
            mp.CACHED_PRODUCTNAME name,
addons.start_date,
pg.name,
pg.id,
            prod.PRICE addonPrice
        FROM
persons p
 JOIN
            SUBSCRIPTIONS s
on p.id =  s.OWNER_ID
 and p.center = s.OWNER_CENTER
            
join 
SUBSCRIPTION_ADDON addons
 ON
            addons.SUBSCRIPTION_CENTER = s.CENTER
            AND addons.SUBSCRIPTION_ID = s.ID
        JOIN
            MASTERPRODUCTREGISTER mp
        ON
            mp.ID = addons.ADDON_PRODUCT_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            mp.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN
            PRODUCTS prod
        ON
            prod.GLOBALID = mp.GLOBALID
			and prod.CENTER = addons.SUBSCRIPTION_CENTER
    
where
pg.id in( '271' , '277') and 
addons.cancelled = 0 and
addons.start_date > sysdate
SELECT 
     prod.CENTER || 'prod' || prod.ID AS Product_ID,
	 prod.name as Product_Name,
	 prod.center as Club,
	 c.shortname as Club_Name
FROM 
	--subscriptions s
 --JOIN
     PRODUCTS prod
 --ON
    -- prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     --AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     CENTERS c
 ON
     c.id = prod.CENTER
WHERE 
	prod.center in ($$scope$$)
AND 
	prod.PTYPE = 10
order by 2,3 
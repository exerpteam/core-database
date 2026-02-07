-- This is the version from 2026-02-05
--  
WITH
    mpr AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    (xpath('//subscriptionType/subscriptionNew/product/requiredRole/text()', XMLPARSE(DOCUMENT convert_from(mpr.product, 'UTF-8'))))[1] AS requiredRole,
                    mpr.*
                FROM
                    masterproductregister mpr 
            ) t1
        WHERE
                
                globalid like 'PLUS_____________'
                AND requiredRole IS NULL
                AND state = 'ACTIVE'
    ),
plus_products AS
(
        SELECT pr.CENTER, pr.PRICE, pr.name, pr.GLOBALID
         FROM mpr JOIN PRODUCTS pr ON mpr.GLOBALID = pr.GLOBALID
         WHERE pr.BLOCKED = 0
)
SELECT
        c.id        AS "Center ID",
        c.name      AS "Center name",
        c.address2  AS "Address",
        c.zipcode   AS "Zipcode",
        c.city      AS "City",
        c.LONGITUDE AS "Longitude",
        c.LATITUDE  AS "Lattitude",
        prod.price  AS "Core price",
        prod2.price AS "Core og Hold price",
        pp.price AS "Plus Price",
        pp.GLOBALID AS "Plus GlobalID",
		start_cea.TXT_VALUE AS "Temp closed start",
		stop_cea.TXT_VALUE AS "Temp closed end"
FROM
    centers c
LEFT JOIN
    products prod
ON
    c.id = prod.center
AND prod.name = 'Core'
AND prod.blocked = 0
LEFT JOIN
    products prod2
ON
    c.id = prod2.center
AND prod2.name = 'Core og Hold'
AND prod2.blocked = 0
LEFT JOIN plus_products pp
ON
        pp.CENTER = c.id

LEFT JOIN
	CENTER_EXT_ATTRS start_cea
ON
	c.ID = start_cea.CENTER_ID
AND	start_cea.NAME = 'TEMPCLOSEDSTART'

LEFT JOIN
	CENTER_EXT_ATTRS stop_cea
ON
	c.ID = stop_cea.CENTER_ID
AND	stop_cea.NAME = 'TEMPCLOSEDEND'

where c.country = 'DK'    
AND c.id in (:scope)
AND c.id != 100
AND c.name not like 'OLD%'

order by
c.id

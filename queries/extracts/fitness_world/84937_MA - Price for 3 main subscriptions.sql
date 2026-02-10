-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    mpr AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    extract(xmltype(mpr.product, 871),'//subscriptionType/subscriptionNew/product/requiredRole/text()').getStringVal() AS requiredRole,
                    mpr.*
                FROM
                    masterproductregister mpr 
            )
        WHERE
                
                globalid like 'PLUS_____________'
                AND requiredRole IS NULL
                AND state = 'ACTIVE'
    ),
plus_products AS
(
        SELECT pr.CENTER, pr.PRICE, pr.name, pr.GLOBALID
         FROM mpr JOIN FW.PRODUCTS pr ON mpr.GLOBALID = pr.GLOBALID
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
		ext.TEMPCLOSEDSTART as "Temp closed start",
		ext.TEMPCLOSEDEND as "Temp. closed end"
		
FROM
    centers c

JOIN
	CENTER_EXT_ATTRS ext
ON
	 c.id = ext.center_id
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
where c.country = 'DK'    
AND c.id in (:scope)
AND c.id != 100
AND c.name not like 'OLD%'

order by
c.id
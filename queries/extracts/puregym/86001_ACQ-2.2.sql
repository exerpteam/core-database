WITH
    globalRounding AS
    (
        SELECT
            sys.*,
            sys.txtvalue AS rounding
        FROM
            systemproperties SYS
        WHERE
            sys.globalid = 'FINANCE_ROUND'
        AND sys.scope_type = 'A'
        AND sys.scope_id = 2
    )
SELECT DISTINCT
    p.globalid                             AS "GlobalId",
    pg.id                                  AS "ProductGroup",
    pp.PRICE_MODIFICATION_NAME             AS "DiscountType",
    pp.PRICE_MODIFICATION_AMOUNT::FLOAT(4) AS "Discount",
	pp.VALID_FOR						   AS "ValidFor",
    CASE
        WHEN pp.PRICE_MODIFICATION_ROUNDING IS NULL
        THEN globalRounding.rounding
        ELSE pp.PRICE_MODIFICATION_ROUNDING
    END AS "Rounding"
FROM
    PRIVILEGE_SETS ps
JOIN
    PRODUCT_PRIVILEGES pp
ON
    ps.ID = pp.PRIVILEGE_SET
CROSS JOIN
    globalRounding globalRounding
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    pp.REF_GLOBALID = mpr.globalid
LEFT JOIN
    products p
ON
    p.globalid = mpr.globalid
AND pp.ref_type = 'GLOBAL_PRODUCT'
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pp.ref_id = pg.id
AND pp.ref_type = 'PRODUCT_GROUP'
WHERE
ps.id IN (:privilegeset_id)
AND pp.VALID_TO IS NULL
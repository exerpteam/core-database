-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4964
SELECT
    CASE WHEN mpr.SCOPE_TYPE = 'T' THEN 'System'
         WHEN mpr.SCOPE_TYPE = 'C' THEN c.SHORTNAME
         WHEN mpr.SCOPE_TYPE = 'A' THEN a.NAME
    END "Scope",
    mpr.GLOBALID                AS "Global Name",
    mpr.CACHED_PRODUCTNAME      AS "Product Name",
    price_table.start_Date      AS "Product price - Start date",
    price_table.normal_Price    AS "Product price",
    pgs.name    AS "Product Groups",
    pac.NAME                    AS "Account configuration", 
    rol.roleNAME                AS "Required role",
    sg.name                     AS "Staff Group",
    extractvalue(xmltype(mpr.PRODUCT, 871), '//product/privilegeNeeded') AS "Purchase requires privilege",
    extractvalue(xmltype(mpr.PRODUCT, 871), '//product/showOnWeb') AS "Show on web",
    extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/@qty') AS "Can be bought",
    extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/period') AS "Person",
    extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/period/@unit') AS "Type",
    CASE WHEN extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/type') = 0 
         THEN 'Sliding'
         WHEN extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/type') = 1
         THEN 'Calendar'
         ELSE null
    END AS "Type",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/period')  AS "Valid for",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/period/@unit') AS "Period",
    CASE WHEN extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/period/@round') = 'NONE'
         THEN '0'
         WHEN extractvalue(xmltype(mpr.PRODUCT, 871), '//product/maxBuy/type') = 'DOWN'
         THEN '1'
         ELSE null
    END AS "Round",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/clipCount')  AS "Clips",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/productRestriction/ageRestriction/@type') AS "Age",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/productRestriction/ageRestriction') AS "Number",
    extractvalue(xmltype(mpr.PRODUCT, 871), '/clipcardType/productRestriction/sexRestriction/@type') AS "Available to",
    mpr.WEBNAME                         AS "Web Name",
    mpr.MAPI_DESCRIPTION                AS "Description",
    mpr.MAPI_RANK                       AS "Rank",
    mpr.MAPI_SELLING_POINTS             AS "Selling points",
    privs.name                          AS "Privilege Set",
    privs.USAGE_QUANTITY                AS "Quantity",
    CASE WHEN privs.USAGE_DURATION_UNIT = 1 THEN privs.USAGE_DURATION_VALUE || ' day'
         WHEN privs.USAGE_DURATION_UNIT = 0 THEN privs.USAGE_DURATION_VALUE || ' week'
         WHEN privs.USAGE_DURATION_UNIT = 2 THEN privs.USAGE_DURATION_VALUE || ' month'
         WHEN privs.USAGE_DURATION_UNIT = 3 THEN privs.USAGE_DURATION_VALUE || ' year'
         WHEN privs.USAGE_DURATION_UNIT = 4 THEN privs.USAGE_DURATION_VALUE || ' hour'
         WHEN privs.USAGE_DURATION_UNIT = 5 THEN privs.USAGE_DURATION_VALUE || ' minute'
    END AS "Duration",
    privs.PUNISHMENT                    AS "Sanction",
    privs.USAGE_USE_AT_PLANNING         AS "Deduct at planning"
FROM
   MASTERPRODUCTREGISTER mpr
LEFT JOIN 
(
select mpr.ID, listagg(pg.name,',') within group (order by pg.id) as name
FROM
   MASTERPRODUCTREGISTER mpr
LEFT JOIN 
   TABLE (xmlsequence (extract ( xmltype(mpr.PRODUCT, 871), '//product/productGroupKeys/productGroupKey'))) pgs  ON (1=1)
LEFT JOIN
   PRODUCT_GROUP pg
ON
   pg.id = extractvalue (Value (pgs), '.')
WHERE 
   mpr.CACHED_PRODUCTTYPE = 4 
GROUP BY mpr.ID
) pgs
ON
   pgs.id = mpr.id
LEFT JOIN
   PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
   pac.id = extractvalue(xmltype(mpr.PRODUCT, 871), '//product/productAccountConfiguration/id')
LEFT JOIN 
   ROLES rol
ON 
   rol.id = extractvalue(xmltype(mpr.PRODUCT, 871), '//product/requiredRole')
LEFT JOIN 
  STAFF_GROUPS sg
ON 
  to_char(sg.id) = extractvalue(xmltype(mpr.PRODUCT, 871), '//product/assignedStaffGroup')
LEFT JOIN
  (
SELECT pg.GRANTER_ID, ps.name, pg.USAGE_QUANTITY, pg.USAGE_DURATION_VALUE, pp.NAME PUNISHMENT, pg.USAGE_USE_AT_PLANNING, pg.USAGE_DURATION_UNIT
from
  BOOKING_PRIVILEGES bp 
JOIN
  PRIVILEGE_SETS ps ON bp.PRIVILEGE_SET = ps.id 
JOIN
  PRIVILEGE_GRANTS pg ON pg.PRIVILEGE_SET = ps.id 
LEFT JOIN
  PRIVILEGE_PUNISHMENTS pp
ON 
  pp.ID = pg.PUNISHMENT
WHERE
  pg.VALID_TO is null
  and bp.VALID_TO is null  
) privs
ON
  privs.GRANTER_ID = mpr.ID
LEFT JOIN 
  centers c
ON
  c.ID = mpr.SCOPE_ID
LEFT JOIN 
  areas a
ON
  a.ID = mpr.SCOPE_ID
LEFT JOIN
  xmltable(
        '//clipcardType/product/prices/price'
        PASSING xmltype(mpr.product,871)
        COLUMNS
            start_Date VARCHAR2(4000) path '@start', 
            normal_Price VARCHAR2(100) path 'normalPrice'
  ) price_table
ON (1=1)
WHERE
--mpr.ID = 363 AND 
CACHED_PRODUCTTYPE = 4  -- only clipcards
AND 
mpr.SCOPE_TYPE = 'A' AND mpr.SCOPE_ID = 2

  
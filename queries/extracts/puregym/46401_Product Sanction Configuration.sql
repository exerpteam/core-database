-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4066
 SELECT
         mpr.CACHED_PRODUCTNAME AS "Product Name",
         --mpr.CACHED_PRODUCTTYPE,
         mpr.GLOBALID AS "Product Global Id",
         c.NAME AS "Center Name",
         a.NAME AS "Area Name",
         mpr.STATE AS "Product State",
         ps.NAME AS "Privilege Set",
         --pg.PUNISHMENT,
         pp.NAME AS "Sanction"
 FROM
         MASTERPRODUCTREGISTER mpr
 JOIN
         PRIVILEGE_GRANTS pg
                 ON pg.GRANTER_ID = mpr.ID
                    AND pg.GRANTER_SERVICE = 'GlobalSubscription'
                    AND pg.VALID_TO IS NULL
 JOIN
         PRIVILEGE_SETS ps
                 ON ps.ID = pg.PRIVILEGE_SET
 LEFT JOIN PRIVILEGE_PUNISHMENTS pp ON pg.PUNISHMENT = pp.ID
 LEFT JOIN CENTERS c ON mpr.SCOPE_ID = c.ID AND mpr.SCOPE_TYPE = 'C'
 LEFT JOIN AREAS a ON mpr.SCOPE_ID = a.ID AND mpr.SCOPE_TYPE = 'A'
 WHERE
         mpr.STATE = 'ACTIVE'
         AND mpr.CACHED_PRODUCTTYPE = 10
 ORDER BY
         mpr.GLOBALID,
         ps.NAME

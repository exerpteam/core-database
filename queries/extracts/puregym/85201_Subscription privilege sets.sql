-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
mpr.globalid "Global ID", 
--mpr.ID MasterProductId,
     mpr.SCOPE_TYPE "Scope Type",
     mpr.SCOPE_ID "Scope ID",
     c.SHORTNAME "Centre short name",
     mpr.CACHED_PRODUCTNAME "Subscription name",
     ps.ID "Privilege Set ID",
     ps.NAME "Privilege Set Name"
 FROM
     MASTERPRODUCTREGISTER mpr
 JOIN
     PRIVILEGE_GRANTS pgr
 ON
     pgr.GRANTER_ID = mpr.ID
     AND pgr.GRANTER_SERVICE = 'GlobalSubscription'
         AND pgr.VALID_TO is null
 JOIN
     PRIVILEGE_SETS ps
 ON
     ps.ID = pgr.PRIVILEGE_SET
 LEFT JOIN
     CENTERS c
 ON
     c.ID = mpr.SCOPE_ID
     AND mpr.SCOPE_TYPE = 'C'
Order by
mpr.globalid,
 mpr.CACHED_PRODUCTNAME,
c.SHORTNAME

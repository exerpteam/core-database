-- The extract is extracted from Exerp on 2026-02-08
-- Previously called: ST-592 - VA Membership Subscription Config. THis was used to get all the priv sets within the subscriptions and you can ask them to be removed or added in bulk via a ST.
 SELECT
     mpr.ID MasterProductId,
     mpr.SCOPE_TYPE,
     mpr.SCOPE_ID,
     c.SHORTNAME centerName,
     mpr.CACHED_PRODUCTNAME,
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

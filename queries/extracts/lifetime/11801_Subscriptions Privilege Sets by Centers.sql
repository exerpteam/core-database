SELECT
        c.id                   "CenterId",
        c.name                 "CenterName",
        mpr.ID                 "MasterProductId",
        mpr.cached_productname "ProductName",
        ps.id                  "PrivilegeSetId",
	    ps.name                "PrivilegeSet",
        --CASE
        --WHEN ps.name IS NULL THEN 'null'
        --ELSE ps.name END AS "PrivilegeSet",
        ps.state AS "State",
        psg.id      "PrivilegeSetGroupId",
        psg.name    "PrivilegeSetGroup"
   FROM
        masterproductregister mpr
LEFT JOIN
        privilege_grants pg
     ON
        pg.granter_id = mpr.id
        AND pg.granter_service = 'GlobalSubscription'
LEFT JOIN
        privilege_sets ps
     ON
        ps.id = pg.privilege_set
LEFT JOIN
        privilege_set_groups psg
     ON
        ps.privilege_set_groups_id = psg.id
   JOIN
        centers c
     ON
        mpr.scope_id = c.id
  WHERE
        pg.valid_to IS NULL
        --AND pg.granter_service = 'GlobalSubscription'
        --AND mpr.definition_key = mpr.id
        --AND mpr.cached_productname =  'Metabolic Conditioning Private 50 Minute Level 1 Monthly'
        --AND mpr.scope_id in (180, 250)
ORDER BY
        mpr.cached_productname,
        ps.name
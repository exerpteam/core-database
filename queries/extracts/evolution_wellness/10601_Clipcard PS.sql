SELECT
        mpr.globalid,
        mpr.cached_productname,
        mpr.state,
        longtodate(pg.valid_from),
        longtodate(pg.valid_to),
        ps.name AS privilege_set_name
FROM evolutionwellness.masterproductregister mpr
JOIN evolutionwellness.privilege_grants pg ON mpr.id = pg.granter_id AND pg.granter_service = 'GlobalCard'
JOIN evolutionwellness.privilege_sets ps ON pg.privilege_set = ps.id
WHERE
        mpr.scope_type = 'A'
        AND mpr.scope_id IN (40,18,24,25)
        AND mpr.cached_producttype = 4
		AND pg.valid_to IS NULL
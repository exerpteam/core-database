SELECT
        mpr.cached_productname,
        mpr.globalid,
        a.name AS area_name,
        ps.name AS ps_name,
        pg.usage_quantity,
        pg.usage_duration_value,
        pg.usage_duration_unit,
        pg.usage_use_at_planning,
        pp.name AS punishment
FROM evolutionwellness.masterproductregister mpr
JOIN evolutionwellness.areas a
        ON mpr.scope_id = a.id
LEFT JOIN evolutionwellness.privilege_grants pg
        ON pg.granter_id = mpr.id
        AND pg.granter_service = 'GlobalCard'
        AND pg.valid_to IS NULL
LEFT JOIN evolutionwellness.privilege_sets ps 
        ON ps.id = pg.privilege_set
LEFT JOIN evolutionwellness.privilege_punishments pp
        ON pp.id = pg.punishment
WHERE
        mpr.scope_id IN (38,6,21)
		AND mpr.cached_producttype = 4
        AND mpr.state = 'ACTIVE'
ORDER BY 1
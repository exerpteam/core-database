-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        prod.globalid
        ,prod.name as Clipcard_Name
        ,ac.name as activity_name
        ,ac.id
FROM
        evolutionwellness.products prod
JOIN
        MASTERPRODUCTREGISTER mpr
        ON mpr.GLOBALID = prod.GLOBALID
        AND mpr.scope_type != 'T'
LEFT JOIN
        PRIVILEGE_GRANTS pgr
        ON pgr.GRANTER_ID = mpr.ID
        AND pgr.valid_to IS NULL
LEFT JOIN
        PRIVILEGE_SETS ps
        ON ps.ID = pgr.PRIVILEGE_SET  
LEFT JOIN
        evolutionwellness.booking_privileges bp
        ON bp.privilege_set = ps.id
LEFT JOIN
        evolutionwellness.participation_configurations pc
        ON pc.access_group_id = bp.group_id 
LEFT JOIN
        evolutionwellness.activity ac
        ON ac.id = pc.activity_id                                              
WHERE
        prod.PTYPE in (4)  
        AND
        prod.center IN (:Scope)       
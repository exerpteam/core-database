-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    mpr.ID "MasterProductId",
    mpr.cached_productname "ProductName",
    ps.id "PrivilegeSetId",
    ps.name "PrivilegeSet",
    ps.state AS "State",
    psg.id "PrivilegeSetGroupId",
    psg.name "PrivilegeSetGroup"
FROM
    privilege_grants pg
JOIN
    masterproductregister mpr
ON
    pg.granter_id = mpr.id
JOIN
    privilege_sets ps
ON
    ps.id = pg.privilege_set
LEFT JOIN
    goodlife.privilege_set_groups psg
ON
    ps.privilege_set_groups_id = psg.id
WHERE
    pg.granter_service = 'GlobalSubscription'
    AND mpr.definition_key = mpr.id
    AND pg.valid_to IS NULL
ORDER BY
    mpr.ID ,
    mpr.cached_productname,
    ps.name,
    psg.name
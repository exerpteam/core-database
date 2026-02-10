-- The extract is extracted from Exerp on 2026-02-08
--  
WITH cte_system_information as (
    SELECT
        case when areas.parent is null then 'T' else 'A' end as scope_type,
        areas.id,
        areas.name
    FROM areas
    where blocked = false
    UNION ALL
    SELECT
        'C' as scope_type,
        area_centers.center as id, -- centerid
        areacenter_to_center_fk.name as name
    FROM area_centers
    LEFT JOIN centers as areacenter_to_center_fk
        ON area_centers.center = areacenter_to_center_fk.id
)

SELECT
    systemproperties.id,
    systemproperties.globalid,
    systemproperties.scope_type,
    systemproperties.scope_id,
    cte_system_information.name as scope_name,
    systemproperties.client,
    systemproperties.txtvalue,
    systemproperties.mimetype,
    systemproperties.mimevalue,
    systemproperties.link_type,
    systemproperties.link_id
FROM systemproperties
left join cte_system_information
ON systemproperties.scope_type = cte_system_information.scope_type
and systemproperties.scope_id = cte_system_information.id

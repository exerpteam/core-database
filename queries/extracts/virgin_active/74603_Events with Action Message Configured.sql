-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        etc.id,
        etc.name,
        a.name AS area_configured,
        etc.event_source_service,
        etc.action_type,
        mtc.ranking,
        (CASE mtc.delivery_method_id 
                WHEN 0 THEN 'STAFF'
                WHEN 1 THEN 'EMAIL'
                WHEN 2 THEN 'SMS'
                WHEN 3 THEN 'PERSONAL_INTERFACE'
                WHEN 4 THEN 'BLOCK_PERSONAL_INTERFACE'
                WHEN 5 THEN 'LETTER'
        END) AS delivery_method,
        mtc.delivery_method_id ,
        t.description AS template_name
FROM virginactive.event_type_config etc
JOIN virginactive.message_type_config_relations mtc ON mtc.event_type_config_id = etc.id
LEFT JOIN virginactive.templates t ON t.id = mtc.template_id
LEFT JOIN virginactive.areas a ON etc.scope_type = 'A' AND etc.scope_id = a.id
WHERE
        etc.state = 'ACTIVE'
        AND etc.action_type = 'MESSAGE'
ORDER BY
        etc.scope_id,
        etc.id,
        mtc.ranking
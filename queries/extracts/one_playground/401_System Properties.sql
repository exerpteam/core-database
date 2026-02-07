SELECT 
        sp.id
        ,sp.globalid
        ,sp.scope_type
        ,sp.scope_id
        ,CASE 
                WHEN sp.txtvalue IS NOT NULL THEN sp.txtvalue
                ELSE sp.mimetype
        END as system_property_value                                 
FROM
        systemproperties sp   
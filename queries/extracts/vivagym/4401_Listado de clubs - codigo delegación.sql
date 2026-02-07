 SELECT
            c.id as "Club ID Exerp",
            cea.txt_value as "Codigo Delegacion", 
            c.name as "Club"
       FROM
            centers c
        LEFT JOIN center_ext_attrs cea ON cea.center_id = c.id AND cea.name = 'IdDelegacion'
        ORDER BY c.id 
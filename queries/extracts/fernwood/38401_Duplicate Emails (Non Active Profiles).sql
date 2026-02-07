SELECT DISTINCT
    p_inactive.center,
    p_inactive.id,
    pea_inactive.txtvalue AS email,
    p_inactive.center || 'p' ||p_inactive.id AS "PERSONKEY" 
    
FROM fernwood.persons p_inactive

JOIN fernwood.person_ext_attrs pea_inactive
    ON pea_inactive.personcenter = p_inactive.center
    AND pea_inactive.personid = p_inactive.id
    AND pea_inactive.name = '_eClub_Email'
    
WHERE p_inactive.status NOT IN (1,3) -- Inactive / Lead / Guest etc
    AND p_inactive.center IN (:center)
    AND pea_inactive.txtvalue IN 
                        (
                         SELECT pea_active.txtvalue
     
                         FROM fernwood.persons p_active
      
                         JOIN fernwood.person_ext_attrs pea_active
                               ON pea_active.personcenter = p_active.center
                               AND pea_active.personid = p_active.id
                               AND pea_active.name = '_eClub_Email'

                         WHERE p_active.status IN (1,3) -- Active / Temp Inactive
                        )
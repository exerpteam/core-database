SELECT
        r.id
        ,r.rolename        
FROM
        leejam.roles r
WHERE
        is_action IS FALSE 
        AND
        blocked IS FALSE
ORDER BY 2               
              
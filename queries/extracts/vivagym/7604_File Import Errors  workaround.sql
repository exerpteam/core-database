SELECT        
        ci.id as file_id,
        ch.name as clearinghouse_name, 
        ci.filename,
        ci.received_date,
        ci.generated_date
FROM 
        vivagym.clearing_in ci
JOIN
        vivagym.clearinghouses ch
ON      
        ch.id = ci.clearinghouse
WHERE
        ch.id NOT IN (1, 201)
        AND ci.errors IS NOT NULL
ORDER BY 3 desc,2
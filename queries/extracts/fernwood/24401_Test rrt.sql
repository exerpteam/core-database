-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        CAST(generate_series(CAST(:From AS DATE) , CAST(:To AS DATE), '1 month') AS DATE) AS gen_ser
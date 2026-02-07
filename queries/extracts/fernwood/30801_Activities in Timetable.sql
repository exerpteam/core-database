WITH 
params AS
(
    SELECT
        datetolongC(TO_CHAR(CAST(:StartDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID
    FROM
        centers c
)
SELECT DISTINCT 
        a.name AS activity_name
        ,a.id AS activity_id
        ,c.name AS club
FROM
        bookings b
JOIN
        params
        ON params.center_id = b.center      
JOIN
        activity a
        ON a.id = b.activity  
JOIN
        centers c
        ON c.id = b.center                
WHERE
        b.center in (:Scope) 
        AND
        a.state = 'ACTIVE' 
        AND
        b.starttime > params.FromDate    
ORDER BY 1           
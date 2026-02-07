SELECT DISTINCT 
        c.id AS "Center"
        ,c.name AS "Name"
        ,c.startupdate AS "Center start up date"                           
FROM
        licenses l
JOIN
        centers c ON c.id = l.center_id 
WHERE
        (l.stop_date IS NULL OR l.stop_date > current_date)    
        AND
        c.id NOT IN (12,1,102,308,100,602,11,214,105,999,219,322)
         
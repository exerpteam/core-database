-- This is the version from 2026-02-05
--  
SELECT
             ac.CENTER,
             c.name AS centername,
             c.shortname,
             c.zipcode,
             'Danmark FW' as scope,
             case when a.id in (4,5,6,3)
             then a.name
             when a.id in (420,436,435,433)
             then pa2.name
             else pa.name end as "Scope 1",      
             
             case 
             when a.parent in (337)
             then pa.name
             when a.id not in (4,5,6,3)           
             then a.name
             else '' end as "Scope 2", 
             
             case 
             when a.id in (420,433,435,436,420)           
             then a.name
             else '' end as "Scope 3" 
             
             
                        
                                 
             
             
         FROM
             AREAS a
         JOIN
             AREA_CENTERS ac
         ON
             a.ID = ac.AREA
         JOIN
             areas pa
         ON
             a.parent = pa.id                    
          
             
         JOIN
             centers c
         ON
             ac.center = c.id
        left JOIN
             areas pa2
         ON
             pa.parent = pa2.id    
             
             
             
             where a.root_area = 1
             and a.id not in (33,34,37,39,133,135,31,2,32,1,134)
             and a.blocked != 'true'
select
    e.name,
    count(eu.id) as times_used,
       (select  
             max(eclub2.longtodate(eu2.time)) 
        from 
             eclub2.extract_usage eu2
        join eclub2.extract e2
          on
             eu2.extract_id = e2.id
        where
            e2.name = e.name
       ) as last_used,

   (select  
         eu3.employee_center||'p'||eu3.employee_id 
    from 
         eclub2.extract_usage eu3
    join eclub2.extract e3
      on
         eu3.extract_id = e3.id
    where
         e3.name = e.name
         and eu3.time = 
                        (select
                                  max(eu4.time)
                            from 
                                  eclub2.extract_usage eu4
                             join eclub2.extract e4
                               on
                                  eu4.extract_id = e4.id
                            where
                                  e4.name = e.name
                        )          
                
   ) as last_user
       
from
     eclub2.extract_usage eu
join eclub2.extract e
    on
    eu.extract_id = e.id
group by
    e.name
order by
    e.name
SELECT DISTINCT 
        c.shortname AS "Club" 
        ,b.name AS "Class Name"
		,ac.id AS "Activity ID"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Class Date" 
        ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Class Start Time" 
        ,TO_CHAR(longtodateC(b.stoptime,b.center),'YYYY-MM-DD') AS "Class End Date"
        ,TO_CHAR(longtodateC(b.stoptime,b.center),'HH24:MI') AS "Class End Time"
        ,ac.duration_list AS "Duration"        
        ,p.fullname AS "Instructor"        
        ,p.center||'p'||p.id AS "Instructor Person ID"
FROM 
        bookings b
JOIN 
        activity ac
        ON b.activity = ac.id
JOIN 
        centers c
	ON c.id = b.center
LEFT JOIN 
        staff_usage su    		
        ON su.booking_center = b.center
        AND su.booking_id = b.id
        AND su.state != 'CANCELLED'
LEFT JOIN
        fernwood.persons p
        ON p.center = su.person_center
        AND p.id = su.person_id        
WHERE
        b.state != 'CANCELLED'	
        and b.center in (:Scope)
		
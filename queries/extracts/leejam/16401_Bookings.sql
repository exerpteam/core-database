-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (
        SELECT
                /*+ materialize */
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
        )                        
SELECT  
        c.name AS "Club"
        ,b.name AS "Class Name"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Class Date" 
        ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Class Time"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,p.center||'p'||p.id AS "Person ID" 
        ,p.external_id AS "External ID"
        ,c.country AS "Home Country"
        ,TO_CHAR(longtodatec(part.creation_time,part.center),'YYYY-MM-DD') AS "Booking Date (local)"
        ,TO_CHAR(longtodatec(part.creation_time,part.center),'HH24:MI') AS "Booking Time (local)"    
        ,CASE
                WHEN part.user_interface_type IN (0,1,3,4,7) THEN 'Yes'
                ELSE 'No'
        END AS "Force-booked"       
        ,CASE
                WHEN part.on_waiting_list IS TRUE THEN TO_CHAR(longtodatec(part.creation_time,part.center),'YYYY-MM-DD')
                ELSE NULL
        END AS "Waitlist Date (local)"
        ,CASE
                WHEN part.on_waiting_list IS TRUE THEN TO_CHAR(longtodatec(part.creation_time,part.center),'HH24:MI')
                ELSE NULL
        END AS "Waitlist Time (local)"   
        ,CASE
                WHEN part.on_waiting_list IS TRUE THEN
                        CASE
                                WHEN part.user_interface_type IN (0,1,3,4,7) THEN 'Yes'
                                ELSE 'No'
                        END
                ELSE 'N/A'
        END AS "Force-waitlisted"                      
        ,CASE
                WHEN part.state = 'PARTICIPATION' THEN 'Y'
                ELSE 'N'
        END AS "Attendance" 
        ,TO_CHAR(longtodatec(part.showup_time,part.center),'HH24:MI') AS "Check-in time (local)" 
        ,TO_CHAR(longtodatec(part.cancelation_time,part.center),'YYYY-MM-DD') AS "Cancellation date (local)"  
        ,TO_CHAR(longtodatec(part.cancelation_time,part.center),'HH24:MI') AS "Cancellation date (local)"
        ,CASE
                WHEN part.cancelation_interface_type = 1 THEN 'Y'
                ELSE 'N'
        END AS "Cancelled by user"                                                       
FROM    
        participations part
JOIN    
        persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN    
        bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN
        centers c
        ON c.id = b.center        
JOIN    
        params 
        ON params.CENTER_ID = part.booking_center
JOIN 
        activity ac
        ON b.activity = ac.id
        AND ac.activity_type = 2  
JOIN 
        activity_group acg
        ON acg.id = ac.activity_group_id               
                                               
WHERE 
        p.center in (:Scope)
        AND  
        b.starttime BETWEEN params.FromDate AND params.ToDate
-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    e.identity,
    CASE e.ENTITYSTATUS  
        WHEN 1 THEN 'OK'  
        WHEN 2 THEN 'STOLEN'  
        WHEN 3 THEN 'MISSING'  
        WHEN 4 THEN 'BLOCKED'  
        WHEN 5 THEN 'BROKEN'  
        WHEN 6 THEN 'RETURNED'  
        WHEN 7 THEN 'EXPIRED'  
        WHEN 8 THEN 'DELETED'  
        WHEN 9 THEN 'COMPROMISED'  
        WHEN 10 THEN 'FORGOTTEN'  
        WHEN 11 THEN 'BANNED'  
        ELSE 'UNKNOWN' 
    END AS "KORT_STATUS",
    e.ref_center || 'p' || e.ref_ID AS MemberID,
    p.external_ID AS ExternalID,
    CASE 
        WHEN s.STATE = 2 THEN 'ACTIVE' 
        WHEN s.STATE = 3 THEN 'ENDED' 
        WHEN s.STATE = 4 THEN 'FROZEN' 
        WHEN s.STATE = 7 THEN 'WINDOW' 
        WHEN s.STATE = 8 THEN 'CREATED' 
        ELSE 'OTHER' 
    END AS "SUBSCRIPTION STATE",
    CASE p.STATUS 
        WHEN 0 THEN 'LEAD' 
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE' 
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED' 
        WHEN 5 THEN 'DUPLICATE' 
        WHEN 6 THEN 'PROSPECT' 
        WHEN 7 THEN 'DELETED' 
        WHEN 8 THEN 'ANONYMIZED' 
        WHEN 9 THEN 'CONTACT' 
        ELSE 'UNKNOWN' 
    END AS STATUS,
    TO_CHAR(longtodateC(e.START_TIME, e.REF_CENTER), 'YYYY-MM-DD') AS Startdate,
    TO_CHAR(longtodateC(e.STOP_TIME, e.REF_CENTER), 'YYYY-MM-DD') AS Stopdate,
    ASSIGN_EMPLOYEE_CENTER || 'emp' || ASSIGN_EMPLOYEE_ID AS AssignerStaff,
    CASE p.persontype
        WHEN 0 THEN 'Private' 
        WHEN 1 THEN 'Student' 
        WHEN 2 THEN 'Staff' 
        WHEN 3 THEN 'Friend' 
        WHEN 4 THEN 'Corporate' 
        WHEN 5 THEN 'Onemancorporate' 
        WHEN 6 THEN 'Family' 
        WHEN 7 THEN 'Senior' 
        WHEN 8 THEN 'Guest' 
        WHEN 9 THEN 'Child' 
        WHEN 10 THEN 'External_Staff' 
        ELSE 'Undefined' 
    END AS PersonType
FROM
    entityidentifiers e
JOIN persons p ON p.center = e.ref_center AND p.ID = e.ref_ID
JOIN subscriptions s ON p.center = s.owner_center AND p.ID = s.owner_id
WHERE e.identity IN (:cardid)
and s.state = 2

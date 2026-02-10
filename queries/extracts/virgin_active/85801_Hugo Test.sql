-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT 
    CASE 
        WHEN enterprise_subject IS NOT NULL THEN 'Activated'
        ELSE 'Invite_pending'
    END AS MFA_Status,
    CASE 
        WHEN E.last_login IS NULL THEN 'Never logged in - Block login'
        WHEN E.last_login < '2024-11-01' THEN 'Last login date before 011124 - Block login'
        ELSE 'N/A'
    END AS Action,
    CASE p.STATUS  
        WHEN 0 THEN 'LEAD'  
        WHEN 1 THEN 'ACTIVE'  
        WHEN 2 THEN 'INACTIVE'  
        WHEN 3 THEN 'TEMPORARYINACTIVE'  
        WHEN 4 THEN 'TRANSFERRED'  
        WHEN 5 THEN 'DUPLICATE'  
        WHEN 6 THEN 'PROSPECT'  
        WHEN 7 THEN 'DELETED' 
        WHEN 8 THEN 'ANONYMIZED'  
        WHEN 9 THEN 'CONTACT'  
        ELSE 'UNKNOWN' 
    END AS person_STATUS,
    E.center AS Club_ID,              -- Club identifier
    C1.NAME AS Employee_Club_Name,       -- Employee's club name
    E.center || 'emp' || E.id AS Employee_Login_ID,
    E.personcenter || 'p' || E.personid AS Membership_ID,
    p.FULLNAME,
    email.TXTVALUE AS Employee_Email,             -- Member email
    E.last_login,
    E.USE_API
FROM 
    EMPLOYEES E 
JOIN
    PERSONS p ON p.CENTER = E.PERSONCENTER AND p.ID = E.PERSONID
JOIN
    CENTERS C1 ON C1.ID = E.center  
JOIN CENTERS c
 ON
     c.id = e.CENTER 
LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             e.center=email.PERSONCENTER
             AND e.id=email.PERSONID
            AND email.name='_eClub_Email'
             AND email.TXTVALUE IS NOT NULL 
WHERE 
    E.center IN (76,29,34,35,27,421,405,38,438,39,47,12,51,56,57,59,415,2,60,61,422,452,15,6,68,69,410,16,953,425,408,4)
    AND E.Blocked = 0
    AND p.fullname NOT ILIKE '%Exerp%'
        AND p.fullname NOT ILIKE '%Training%'
        AND p.fullname NOT ILIKE '%API%'
        -- Exclude blank or NULL last_login
        AND E.last_login IS NOT NULL
        
        -- Exclude dates older than 2025-01-01
        AND E.last_login >= '2025-01-01'
ORDER BY 
    MFA_Status ASC,
    E.last_login DESC;

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
        CASE  p.STATUS  
                WHEN 0 THEN 'LEAD'  
                WHEN 1 THEN 'ACTIVE'  
                WHEN 2 THEN 'INACTIVE'  
                WHEN 3 THEN 'TEMPORARYINACTIVE'  
                WHEN 4 THEN 'TRANSFERED'  
                WHEN 5 THEN 'DUPLICATE'  
                WHEN 6 THEN 'PROSPECT'  
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED'  
                WHEN 9 THEN 'CONTACT'  
                ELSE 'UNKNOWN' 
        END AS person_STATUS,
        E.center || 'emp' || E.id AS Employee_Login_ID,
        E.personcenter || 'p' || E.personid AS Membership_ID,
        p.FULLNAME,
        E.last_login,
        E.USE_API
FROM 
        EMPLOYEES E 
JOIN
        PERSONS p
        ON p.CENTER = e.PERSONCENTER
        AND p.ID = e.PERSONID
WHERE 
        E.CENTER in (:scope)
        AND E.Blocked = 0

        -- Exclude FULLNAME matches (case-insensitive)
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

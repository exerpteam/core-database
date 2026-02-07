SELECT 
        --EXTERNAL_ID,
        C.Shortname as Club,
        CASE  p.STATUS  
                WHEN 0 THEN 'LEAD'  
                WHEN 1 THEN 'ACTIVE'  
                WHEN 2 THEN 'INACTIVE'  
                WHEN 3 THEN 'TEMPORARYINACTIVE'  
                WHEN 4 THEN 'TRANSFERED'  
                WHEN 5 THEN 'DUPLICATE'  
                WHEN 6 THEN 'PROSPECT'  
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN  'ANONYMIZED'  
                WHEN 9 THEN  'CONTACT'  
                ELSE 'UNKNOWN' 
        END AS person_STATUS,
        Emp.BLOCKED,
        Emp.Center || 'emp' || Emp.ID as Login_ID,
        p.CENTER || 'p' || p.ID member_id,
        p.FULLNAME,
        email.TXTVALUE,
        Emp.LAST_LOGIN,
        Emp.USE_API

FROM 
        EMPLOYEES Emp
JOIN
    PERSONS p
    ON p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID
LEFT JOIN
    PERSON_EXT_ATTRS email
    ON p.center = email.PERSONCENTER
    AND p.id = email.PERSONID
    AND email.name = '_eClub_Email'
JOIN
    CENTERS c
    ON c.id = p.CENTER
WHERE 
        Emp.Center in (:scope)
AND 
        Emp.Blocked = 0
ORDER BY 
        C.Shortname asc,
		Emp.LAST_LOGIN asc
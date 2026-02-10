-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    C.Shortname,
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
    END AS MemberStatus,
    p.center || 'p' || p.id AS PERSONID,
    TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'YYYY-MM-DD HH24:MI:SS') AS NoteCreationTime,
    jrn.name AS Header,
    convert_from(jrn.big_text, 'UTF-8') AS NoteText,
    
    -- Calculate exact age using AGE() function
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.BIRTHDATE)) || ' years ' || 
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, p.BIRTHDATE)) || ' months ' || 
    EXTRACT(DAY FROM AGE(CURRENT_DATE, p.BIRTHDATE)) || ' days' AS exact_current_age,

    jrnCreator.fullname AS CreatorName

FROM journalentries jrn
JOIN persons p ON p.center = jrn.person_center AND p.id = jrn.person_id
JOIN Centers C ON P.center = c.ID
JOIN employees emp ON emp.center = jrn.creatorcenter AND emp.id = jrn.creatorid
JOIN persons jrnCreator ON jrnCreator.center = emp.personcenter AND jrnCreator.id = emp.personid
LEFT JOIN subscriptions s ON s.owner_center = p.center AND s.owner_id = p.id
LEFT JOIN CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER = p.center AND ccc.PERSONID = p.id 
    AND ccc.CLOSED = 0 AND ccc.MISSINGPAYMENT = 1

-- Other payer subquery
LEFT JOIN (
    SELECT DISTINCT rel.center AS PAYER_CENTER, rel.id AS PAYER_ID
    FROM PERSONS mem
    JOIN SUBSCRIPTIONS sub ON mem.center = sub.OWNER_CENTER AND mem.id = sub.OWNER_ID
        AND sub.STATE IN (2, 4, 8)
        AND (sub.end_date IS NULL OR sub.end_date > sub.BILLED_UNTIL_DATE)
    JOIN SUBSCRIPTIONTYPES st ON st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER 
        AND st.id = sub.SUBSCRIPTIONTYPE_ID
    JOIN RELATIVES rel ON rel.RELATIVECENTER = mem.center 
        AND rel.RELATIVEID = mem.id
        AND rel.RTYPE = 12
        AND rel.STATUS < 3
    WHERE st.ST_TYPE = 1 AND mem.persontype NOT IN (2, 8)
) pay_for ON pay_for.payer_center = p.center AND pay_for.payer_id = p.id

WHERE p.blacklisted = '1'
AND jrn.name = 'Blacklisted'
ORDER BY C.Shortname ASC;

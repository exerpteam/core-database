-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        c.name AS "Homeclub name"
        ,p.center||'p'||p.ID AS "Member id"
        ,p.FULLNAME AS "Member full name"
        ,email.TXTVALUE AS "Members e-mail"
        ,mobile.TXTVALUE AS "Members mobile phone number"
        ,pag.Ref AS "Ref."
        ,ch.NAME
FROM persons p
JOIN account_receivables ar 
                ON ar.customercenter = p.center 
                AND ar.customerid = p.id 
                AND ar.ar_type = 4
JOIN payment_accounts pa 
                ON pa.center = ar.center 
                AND pa.id = ar.id 
JOIN payment_agreements pag 
                ON pag.center = pa.active_agr_center
                AND pag.ID = pa.active_agr_id 
                AND pag.subid = pa.active_agr_subid 
JOIN CENTERS c 
                ON c.ID = p.Center
LEFT JOIN PERSON_EXT_ATTRS email
                ON p.id = email.PERSONID
                AND p.Center = email.PERSONCENTER
                AND email.name = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS mobile
                ON p.id = mobile.PERSONID
                AND p.Center = mobile.PERSONCENTER
                AND mobile.name = '_eClub_PhoneSMS'
JOIN CLEARINGHOUSES ch 
                ON ch.ID = pag.clearinghouse
WHERE 
                p.Status Not in (4,5,7,8)
                AND p.SEX != 'C'
                AND p.Center in (:Scope)
               -- and ch.id = 1413

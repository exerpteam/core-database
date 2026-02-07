SELECT 
        c.name AS "Homeclub name"
        ,p.center||'p'||p.ID AS "Member id"
        ,p.FULLNAME AS "Member full name"
        ,email.TXTVALUE AS "Members e-mail"
        ,mobile.TXTVALUE AS "Members mobile phone number"
        ,pag.Ref AS "Ref."
        ,ch.NAME
        ,pag.BANK_REGNO
        ,pag.BANK_ACCNO,
		Case pag.STATE When 1 Then 'Oprettet' When 2 Then 'Oprettelse sendt' When 3 Then 'Fejlet' When 4 Then 'OK' When 5 Then 'Afsluttet bank' When 6 Then 'Afsluttet PBS' When 7 Then 'Afsluttet kunde' When 8 Then 'Afmeld' When 9 Then 'Afmeldelse sendt' When 10 Then 'Afsluttet kreditor' When 13 Then 'Aftale ikke nødvendigt' When 14 Then 'Mangelfuld' Else 'Undefined' End AS "Aftale status",
		pag.ENDED_DATE,
		pag.ENDED_REASON_TEXT
FROM persons p
left JOIN account_receivables ar 
                ON ar.customercenter = p.center 
                AND ar.customerid = p.id 
            --    AND ar.ar_type = 4
left JOIN payment_accounts pa 
                ON pa.center = ar.center 
                AND pa.id = ar.id 
left JOIN payment_agreements pag 
                ON pag.center = pa.active_agr_center
                AND pag.ID = pa.active_agr_id 
                AND pag.subid = pa.active_agr_subid 
left JOIN CENTERS c 
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
               -- p.Status Not in (4,5,7,8)
                p.SEX != 'C'
                AND (p.Center,p.id)in (:members)
               -- and ch.id = 1413

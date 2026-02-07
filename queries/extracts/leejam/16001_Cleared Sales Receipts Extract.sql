WITH params AS MATERIALIZED
(
        SELECT
                c.id AS CENTER_ID,
                CAST(datetolongC(:DateTime,c.id) AS BIGINT) - (:lastruntime*60*1000) AS fromDate,
                CAST(datetolongC(:DateTime,c.id) AS BIGINT) AS toDate
        FROM
                centers c
)               
SELECT
        CASE
                WHEN p.status = 4 THEN transfer.external_id
                ELSE p.external_id 
        END AS "External ID"
        ,inv.center||'inv'||inv.id AS "Transaction number"
        ,email.txtvalue AS "E-mail"
        ,mobile.txtvalue AS "Mobile phone"
        ,TO_CHAR ((longtodatec(inv.entry_time,inv.center)),'YYYY-MM-DD HH24:MI') AS "Transaction created date and time"
        ,TO_CHAR ((longtodatec(ci.issued_date,ci.reference_center)),'YYYY-MM-DD HH24:MI') AS "Transaction cleared date and Time"
        ,p.firstname AS "First name"
        ,p.lastname AS "Last name"
        ,CASE
                WHEN planguage.txtvalue = '12' THEN 'Arabic'
                WHEN planguage.txtvalue = '1' THEN 'English'
        END AS "Preferred Language"
FROM leejam.invoices inv
JOIN params
        ON params.center_id = inv.center 
JOIN leejam.invoice_lines_mt invl
        ON inv.center = invl.center AND inv.id = invl.id   
JOIN leejam.customer_invoice ci
        ON inv.center = ci.reference_center AND inv.id = ci.reference_id
JOIN leejam.persons p
        ON p.center = inv.payer_center AND p.id = inv.payer_id
JOIN leejam.persons cp
        ON cp.center = p.current_person_center AND cp.id = p.current_person_id
LEFT JOIN leejam.person_ext_attrs email
        ON email.personcenter = cp.center AND email.personid = cp.id AND email.name = '_eClub_Email'
LEFT JOIN leejam.person_ext_attrs mobile
        ON mobile.personcenter = cp.center AND mobile.personid = cp.id AND mobile.name = '_eClub_PhoneSMS'    
LEFT JOIN leejam.person_ext_attrs planguage
        ON planguage.personcenter = cp.center AND planguage.personid = cp.id AND planguage.name = '_eClub_LanguagePreferred'  
LEFT JOIN leejam.persons transfer
        ON transfer.center = p.current_person_center AND transfer.id = p.current_person_id AND p.external_id IS NULL                          
WHERE 
        p.country = :Country
        AND 
        p.sex != 'C'  
        AND ci.issued_date BETWEEN params.fromDate AND params.toDate
        AND invl.reason IN (0,1,9,21,27,30,31) 
        AND invl.total_amount != 0
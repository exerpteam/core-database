WITH params AS MATERIALIZED
        (
                SELECT
                        TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS cutdate,
                        c.id AS CenterID
                FROM evolutionwellness.centers c
                WHERE c.country = 'ID'
        )
SELECT
        p.external_id AS "Member Number"
        ,p.external_id AS "Billing Reference"
        ,'' AS "Legacy Payer Id"
        ,CASE
                WHEN PayerNationalID.txtvalue IS NULL THEN p.national_id
                ELSE PayerNationalID.txtvalue
        END AS "New Payer Id"
        ,ch.name AS "Issuing Bank Name"
        ,pag.bank_account_holder AS "Account Name"
        ,pag.bank_accno AS "Account Number"
        ,'' AS "Credit Card Type"
        ,pag.bank_accno AS "Credit Card Number"
        ,'' AS "Expiry Date"
        ,c.external_id||'-'||c.id AS "Club Code / Club Name"
        ,'' AS "Originator Id"
        ,longtodatec(s.creation_time, s.center) AS "Join Date"
        ,s.billed_until_date + 1 AS "First Billing Date"
FROM 
        evolutionwellness.persons p
JOIN 
        evolutionwellness.account_receivables ar 
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid 
        AND ar.ar_type = 4
JOIN 
        evolutionwellness.payment_accounts pac 
        ON ar.center = pac.center 
        AND ar.id = pac.id
JOIN 
        evolutionwellness.payment_agreements pag 
        ON pac.center = pag.center 
        AND pac.id = pag.id
JOIN 
        evolutionwellness.clearinghouses ch 
        ON pag.clearinghouse = ch.id
JOIN
        evolutionwellness.subscriptions s
        ON p.center = s.owner_center
        AND p.id = s.owner_id
        AND s.state IN (2,4)
JOIN
        evolutionwellness.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        AND st.st_type != 0
LEFT JOIN
        evolutionwellness.person_ext_attrs PayerNationalID
        ON PayerNationalID.personcenter = p.center
        AND PayerNationalID.personid = p.id
        AND PayerNationalID.name = 'PayerNationalID' 
JOIN
        evolutionwellness.centers c
        ON c.id = p.center  
JOIN
        params
        ON params.CenterID = c.id                                     
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND pag.clearinghouse IN (1202,1402,1401,1602,1201,1601)
        AND params.cutdate - longtodatec(pag.creation_time,pag.center)::DATE < :numberofdays
        
        
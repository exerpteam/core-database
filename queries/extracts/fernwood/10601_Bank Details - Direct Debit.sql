SELECT DISTINCT
        p.center||'p'||p.id AS "PersonID"
        ,c.name AS "Club Name"
        ,pa.example_reference AS "Payment Agreement Ref"
        ,TO_CHAR(longtodateC(pa.creation_time,pa.center),'YYYY-MM-DD')
        ,ch.name AS "Clearing House"
        ,pa.extra_info AS "Bank Name"
        ,pa.bank_name AS "Branch Name"
	,pa.bank_account_holder
        ,pa.bank_regno AS "BSB"
        ,pa.bank_accno AS "Account Number" 
FROM        
        persons p
JOIN
        subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id
        AND s.state in (1,3)
JOIN
        account_receivables ar 
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid 
        AND ar.ar_type = 4
JOIN 
        payment_accounts pac 
        ON pac.center = ar.center 
        AND pac.id = ar.id
JOIN 
        payment_agreements pa 
        ON pac.active_agr_center = pa.center 
        AND pac.active_agr_id = pa.id 
        AND pac.active_agr_subid = pa.subid 
        AND pa.state IN (4) 
	AND pa.clearinghouse != 2
JOIN
        clearinghouses ch
        ON ch.id = pa.clearinghouse 
JOIN
	centers c
	ON c.id = p.center                                                                                                                                     
WHERE
        p.center in (:Scope) 
-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2195
https://clublead.atlassian.net/browse/EC-2304
SELECT  
        c.shortname AS "Club"
        ,p.center||'p'||p.id AS "Person ID"
		,p.external_id AS "External ID"
        ,p.fullname AS "Person Name"
        ,ar.balance AS "Account Balance"
        ,sum(art.unsettled_amount) AS "Outstanding Balance"
        ,(CASE  
                WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
                WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
                ELSE 'FF_Invoice'
        END) AS "Payment Cycle"
FROM
        persons p
JOIN 
        account_receivables ar 
        ON ar.customercenter = p.center 
        AND ar.customerid = p.id
        AND ar.ar_type = 4
JOIN 
        payment_accounts pac 
        ON ar.center = pac.center 
        AND ar.id = pac.id
JOIN 
        payment_agreements pag 
        ON pac.active_agr_center = pag.center 
        AND pac.active_agr_id = pag.id 
        AND pac.active_agr_subid = pag.subid
        AND pag.state = 4
JOIN 
        centers c 
        ON c.id = pag.center
LEFT JOIN 
        ar_trans art 
        ON art.center = ar.center 
        AND art.id = ar.id
        AND art.status != 'CLOSED'
        AND art.due_date < current_date                                     
WHERE
         p.status NOT IN (4,5,7,8)
         AND 
         ar.balance < 0
         AND 
         p.center in (:Scope)
         AND
         pag.payment_cycle_config_id in (:PaymentCycle)
GROUP BY
        p.center
        ,p.id
        ,p.fullname
        ,ar.balance
        ,c.shortname
        ,pag.payment_cycle_config_id
SELECT
        c.shortname AS "Club Name"
        ,p.center || 'p' || p.id AS PersonId
        ,p.external_id AS "External ID"
        ,(CASE  
                WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
                WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
                ELSE 'FF_Invoice'
        END) AS "Payment Cycle"       
FROM fernwood.persons p
JOIN fernwood.account_receivables ar ON ar.customercenter = p.center AND ar.customerid = p.id AND ar.ar_type = 4
JOIN fernwood.payment_accounts pac ON pac.center = ar.center AND pac.id = ar.id
JOIN fernwood.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN fernwood.centers c on c.id = p.center
WHERE
        p.status in (1,3)
        AND
        p.center in (:Scope)
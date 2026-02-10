-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS "PERSONKEY",
        p.external_id,
        pag.clearinghouse,
        ch.name,
        ar.balance
FROM account_receivables ar
JOIN persons p
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid                     
JOIN payment_accounts pac 
        ON pac.center = ar.center
        AND pac.id = ar.id
JOIN
        payment_agreements pag
        ON pag.center = pac.active_agr_center
        AND pag.id = pac.active_agr_id
        AND pag.subid = pac.active_agr_subid
JOIN
        evolutionwellness.clearinghouses ch
        ON ch.id = pag.clearinghouse
WHERE
        ar.balance < 0
        AND ar.ar_type = 4
        AND p.sex != 'C'
        AND pag.clearinghouse IN (801,602,1202,1402,1401,1602,1601)
        AND pag.state = 4
        AND p.center IN (304,305,306,307,308,310,311,312,313,314,315,316,317,318,319,320,321,322,324,325,326,327,329,332,334,336,337,342,345,346,347,349,350,351)                 

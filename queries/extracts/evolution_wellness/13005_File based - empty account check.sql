-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        ar.customercenter||'p'||ar.customerid as personID
        ,ch.name
        ,pr.req_date
        ,pag.*
FROM 
        payment_requests pr
JOIN 
        clearinghouses ch 
        ON pr.clearinghouse_id = ch.id
JOIN 
        payment_agreements pag 
        ON pr.center = pag.center 
        AND pr.id = pag.id 
        AND pr.agr_subid = pag.subid
JOIN 
        payment_accounts pac 
        ON pac.center = pag.center 
        AND pac.id = pag.id 
JOIN 
        account_receivables ar
        ON ar.center = pac.center 
        AND ar.id = pac.id  
WHERE
        pr.state IN (1)
        AND pr.clearinghouse_id IN (1202,1402,1401,1602,1601)
        AND pag.bank_accno IS NULL
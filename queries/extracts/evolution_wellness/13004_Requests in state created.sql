SELECT
        ar.customercenter||'p'||ar.customerid as personID
FROM
        evolutionwellness.payment_requests pr
JOIN
        evolutionwellness.payment_agreements pag
        ON pr.center = pag.center 
        AND pr.id = pag.id 
        AND pr.agr_subid = pag.subid
JOIN 
        evolutionwellness.payment_accounts pac 
        ON pac.center = pag.center 
        AND pac.id = pag.id 
JOIN 
        evolutionwellness.account_receivables ar
        ON ar.center = pac.center 
        AND ar.id = pac.id               
WHERE
        pr.req_date = '2025-06-01'
        AND
        pr.state = 1
        AND
        pag.state = 1   
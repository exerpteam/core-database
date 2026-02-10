-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (
                SELECT
                        datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                        c.id AS CENTER_ID,
                        CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                        centers c
        )
SELECT
        longtodatec(inv.entry_time,inv.center) AS Date
        ,p.center||'p'||p.id AS "Exerp ID"
        ,c.shortname AS Location
        ,p.fullname AS Name
        ,invl.text AS "Products"
        ,invl.total_amount AS "Payment Amount"     
FROM
        invoices inv
JOIN
        invoice_lines_mt invl
        ON invl.center = inv.center
        AND inv.id = invl.id
JOIN
        persons p
        ON p.center = inv.payer_center                      
        AND p.id = inv.payer_id
JOIN
        ar_trans art
        ON art.ref_center = invl.center
        AND art.ref_id = invl.id
        AND art.ref_type = 'INVOICE'
JOIN
        art_match artm
        ON artm.art_paid_center = art.center
        AND artm.art_paid_id = art.id
        AND artm.art_paid_subid = art.subid
        AND artm.cancelled_time IS NULL 
JOIN
        ar_trans artp
        ON artp.center = artm.art_paying_center
        AND artp.id = artm.art_paying_id
        AND artp.subid = artm.art_paying_subid               
JOIN
        params
        ON params.center_id = inv.center 
JOIN
        centers c
        ON c.id = inv.center                            
WHERE
        inv.employee_center ||'emp'|| inv.employee_id  IN ('999emp2401','300emp2601','999emp1001','999emp2201') 
        AND
        inv.entry_time BETWEEN params.FromDate AND params.ToDate
        AND 
        inv.center IN (:Scope)

       
               
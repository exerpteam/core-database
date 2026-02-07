WITH params AS MATERIALIZED (
    SELECT
        c.id AS CENTER_ID,

        -- Start date: first day of the month 3 months ago
        datetolongC(
            TO_CHAR(
                date_trunc('month', current_date) - INTERVAL '2 month',
                'YYYY-MM-DD HH24:MI'
            ),
            c.id
        ) AS FromDate,

        -- End date: last day of that same month
        datetolongC(
            TO_CHAR(
                (date_trunc('month', current_date) - INTERVAL '1 month' - INTERVAL '1 day'),
                'YYYY-MM-DD HH24:MI'
            ),
            c.id
        ) AS ToDate,
        c.id
    FROM
        centers c
)
SELECT DISTINCT
		p.external_id AS MemberID
        ,p.center||'p'||p.id AS PersonID
        ,pag.clearinghouse
FROM
        evolutionwellness.persons p
JOIN
        params ON 
        params.id = p.center        
JOIN
        evolutionwellness.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4   
JOIN
        evolutionwellness.ar_trans art   
        ON art.center = ar.center    
        AND art.id = ar.id   
JOIN 
        evolutionwellness.payment_accounts pac 
        ON ar.center = pac.center 
        AND ar.id = pac.id
JOIN 
        evolutionwellness.payment_agreements pag 
        ON pac.center = pag.center 
        AND pac.id = pag.id
        AND pag.creation_time < params.FromDate
JOIN    
        evolutionwellness.centers c 
        ON c.id = pag.center 
JOIN
        evolutionwellness.payment_requests pr
        ON pr.CENTER = ar.CENTER
        AND pr.ID = ar.ID
        AND pr.request_type = 1             
JOIN
        evolutionwellness.payment_request_specifications prs
        ON pr.INV_COLL_CENTER = prs.CENTER
        AND pr.INV_COLL_ID = prs.ID
        AND pr.INV_COLL_SUBID = prs.SUBID   
                         
WHERE
        p.center IN (:Scope) 
        AND
        pag.active = true
        AND
        pag.state = 4        
        AND
        art.ref_type IN ('INVOICE','ACCOUNT_TRANS')
        AND
        art.status != 'CLOSED'
        AND 
        pr.state = 5
        AND
        art.due_date BETWEEN longtodatec(params.fromdate,params.id) AND longtodatec(params.todate,params.id)  
        AND
        EXTRACT(DAY FROM current_date) = 2    
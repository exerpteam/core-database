WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    to_date(getcentertime(c.id), 'YYYY-MM-DD') AS cutDate,
                    c.ID                                       AS CenterID
                FROM
                    CENTERS c
                JOIN
                    COUNTRIES co
                ON
                    c.COUNTRY = co.ID
            )
SELECT 
        p.center ||'p'|| p.id AS PersonID
        ,pr.req_amount
        ,pr.req_date 
FROM
        fernwood.persons p
JOIN
        fernwood.cashcollectioncases cc
        ON cc.personcenter = p.center
        AND cc.personid = p.id 
        AND cc.closed IS FALSE
        AND cc.missingpayment IS FALSE       
JOIN    
        account_receivables ar
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
        AND ar.ar_type = 4 
JOIN
        payment_request_specifications prs
        ON ar.center = prs.center
        AND ar.id = prs.id
JOIN
        params
        ON params.CenterID = prs.center                
JOIN
        payment_accounts pac 
        ON pac.center = ar.center
        AND pac.id = ar.id
JOIN
        payment_agreements pag
        ON pag.center = pac.active_agr_center
        AND pag.id = pac.active_agr_id
        AND pag.subid = pac.active_agr_subid   
JOIN
        payment_requests pr
        ON prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid
        AND pr.request_type = 1
        AND pr.state = 12
WHERE
        p.status IN (1,3)
        AND
        p.center IN (:Center)  
        AND
        pr.req_date = params.cutDate-1 
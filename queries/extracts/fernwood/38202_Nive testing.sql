-- The extract is extracted from Exerp on 2026-02-08
--  
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
            ),
            reject_1 AS
            (
                SELECT DISTINCT
                        pr.center,
                        pr.id,
                        pr.subid,
                        p.center || 'p' || p.id AS "PERSONKEY",
                        pr.xfr_info,
                        pr.req_date
                FROM
                        payment_request_specifications prs
                JOIN
                        params
                        ON params.CenterID = prs.center
                JOIN
                        account_receivables ar
                        ON ar.center = prs.center
                        AND ar.id = prs.id
                JOIN
                        persons p
                        ON p.center = ar.customercenter
                        AND p.id = ar.customerid
                JOIN
                        CENTERS c
                        ON c.id = p.center                         
                JOIN
                        payment_requests pr
                        ON prs.center = pr.inv_coll_center
                        AND prs.id = pr.inv_coll_id
                        AND prs.subid = pr.inv_coll_subid
                        AND pr.request_type IN (1,6) --Payment and representations
                        AND pr.state NOT IN (1,2,3,4,8,12,18)
                JOIN
                        payment_accounts pac 
                        ON pac.center = ar.center
                        AND pac.id = ar.id
                JOIN
                        payment_agreements pag
                        ON pag.center = pac.active_agr_center
                        AND pag.id = pac.active_agr_id
                        AND pag.subid = pac.active_agr_subid
                WHERE
                        (
                        pr.req_date = params.cutDate-1
                        AND extract(dow from (to_date(getcentertime(c.id), 'YYYY-MM-DD'))) = 5--friday
                        )
                        AND ar.balance < 0 --Exclude members with positive balance
                        AND ar.ar_type = 4   
                        AND p.sex != 'C'
                        AND prs.open_amount > 0
                        AND pr.clearinghouse_id = 2 --Fernwood CC 
                        AND pag.state = 4
                        AND pr.xfr_info IN ('Do not honour','Not sufficient funds','Refer to card issuer','Transaction not permitted to t','Invalid transaction','Issuer or switch is inoperativ','Connect to api.payway.com.au:4')
                        AND pr.center NOT IN (601,602) --exclude clubs   
                        AND pr.center in (:center)                                                     
                ),
                reject_2 AS
                (
                SELECT DISTINCT
                        pr.center,
                        pr.id,
                        pr.subid,
                        p.center || 'p' || p.id AS "PERSONKEY",
                        pr.xfr_info,
                        pr.req_date
                FROM
                        payment_request_specifications prs
                JOIN
                        params
                        ON params.CenterID = prs.center
                JOIN
                        account_receivables ar
                        ON ar.center = prs.center
                        AND ar.id = prs.id
                JOIN
                        persons p
                        ON p.center = ar.customercenter
                        AND p.id = ar.customerid
                JOIN
                        CENTERS c
                        ON c.id = p.center                         
                JOIN
                        payment_requests pr
                        ON prs.center = pr.inv_coll_center
                        AND prs.id = pr.inv_coll_id
                        AND prs.subid = pr.inv_coll_subid
                        AND pr.request_type IN (1,6) --Payment and representations
                        AND pr.state NOT IN (1,2,3,4,8,12,18)
                JOIN
                        payment_accounts pac 
                        ON pac.center = ar.center
                        AND pac.id = ar.id
                JOIN
                        payment_agreements pag
                        ON pag.center = pac.active_agr_center
                        AND pag.id = pac.active_agr_id
                        AND pag.subid = pac.active_agr_subid
                WHERE
                        (
                        pr.req_date = params.cutDate-2
                        AND extract(dow from (to_date(getcentertime(c.id), 'YYYY-MM-DD'))) = 5 --friday
                        )
                        AND ar.balance < 0 --Exclude members with positive balance
                        AND ar.ar_type = 4   
                        AND p.sex != 'C'
                        AND prs.open_amount > 0
                        AND pr.clearinghouse_id = 2 --Fernwood CC 
                        AND pag.state = 4
                        AND pr.xfr_info IN ('Do not honour','Not sufficient funds','Refer to card issuer','Transaction not permitted to t','Invalid transaction','Issuer or switch is inoperativ','Connect to api.payway.com.au:4')
                        AND pr.center NOT IN (601,602) --exclude clubs    
                        AND pr.center in (:center)
                        AND p.center || 'p' || p.id NOT IN 
                                                        (   
                                                         SELECT DISTINCT
                                                                        reject_1."PERSONKEY"
                                                         FROM
                                                                reject_1
                                                         )
                )
        SELECT
        t.center,
        t.id,
        max(t.subid) as subid,
        t."PERSONKEY",
        t.xfr_info,
        t.req_date
FROM
        (
        SELECT
                *
        FROM
                reject_1
        UNION ALL
        SELECT
                *
        FROM
                reject_2
        )t                
WHERE
        t."PERSONKEY" NOT IN 
                (SELECT
                        ar.customercenter||'p'||ar.customerid
                FROM
                        payment_agreements pag
                JOIN
                        payment_accounts pac
                        ON pag.center = pac.active_agr_center
                        AND pag.id = pac.active_agr_id
                        AND pag.subid = pac.active_agr_subid 
                JOIN
                        account_receivables ar
                        ON pac.center = ar.center
                        AND pac.id = ar.id
                WHERE
                        pag.clearinghouse = 1  
                )                                             
GROUP BY
        t.center,
        t.id,
        t."PERSONKEY",
        t.xfr_info,
        t.req_date
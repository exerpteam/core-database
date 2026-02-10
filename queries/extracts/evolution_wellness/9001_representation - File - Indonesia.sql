-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                        EXTRACT(DAY FROM(to_date(getcentertime(c.id), 'YYYY-MM-DD'))) AS dayOfMonth,
                        EXTRACT(dow FROM(to_date(getcentertime(c.id), 'YYYY-MM-DD'))) AS dayOfWeek,
                        EXTRACT(DAY FROM(DATE_TRUNC('month', to_date(getcentertime(c.id), 'YYYY-MM-DD')) + INTERVAL '1 month' - INTERVAL '1 day')) AS lastDayMonth,
                        c.id AS CenterID
                FROM evolutionwellness.centers c
                WHERE c.country = 'ID'
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY",
                pr.xfr_info,
                pr.req_date
        FROM payment_request_specifications prs
        JOIN params par
                ON par.CenterID = prs.center
        JOIN account_receivables ar
                ON ar.center = prs.center 
                AND ar.id = prs.id
        JOIN persons p
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid                     
        JOIN payment_requests pr
                ON prs.center = pr.inv_coll_center
                AND prs.id = pr.inv_coll_id
                AND prs.subid = pr.inv_coll_subid
                AND pr.request_type IN (1) --Payment
                AND pr.state NOT IN (1,2,3,4,8,12,18)
        JOIN payment_accounts pac 
                ON pac.center = ar.center
                AND pac.id = ar.id
        JOIN
                payment_agreements pag
                ON pag.center = pac.active_agr_center
                AND pag.id = pac.active_agr_id
                AND pag.subid = pac.active_agr_subid
        WHERE
                -- THIS CONDITION WILL MAKE THE REPRESENTATIONS TO STOP AFTER MONTH END
                pr.req_date >= par.cutdate
                AND ar.balance < 0
                AND ar.ar_type = 4
                AND p.sex != 'C'
                AND prs.open_amount > 0
                AND pr.clearinghouse_id IN (1202,1402,1401,1602,1601)
                AND pag.state = 4
                AND pr.center BETWEEN 300 AND 399 
                -- THIS CONDITION WILL MAKE SURE WE DO NOT REPRESENT ON COLLECTION DAY = 1
                AND par.dayOfMonth != 1
                AND
                (
                        -- Fixed Dates: 2nd, 3rd, and 10th of the month
                        par.dayOfMonth IN (5,14,27)

                )
                -- Maximum 8 attempts including the regular billing on the 1st
                AND NOT EXISTS
                (
                        SELECT
                             1
                        FROM
                                payment_requests rep_req
                        WHERE
                                rep_req.inv_coll_center = prs.center
                                AND rep_req.inv_coll_id = prs.id
                                AND rep_req.inv_coll_subid = prs.subid
                                AND rep_req.request_type = 6
                                AND rep_req.state NOT IN (8)
                        HAVING COUNT(*) >= 7 
                )
) t1
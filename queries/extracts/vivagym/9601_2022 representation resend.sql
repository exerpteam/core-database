SELECT
        t1.*
FROM
(
      WITH params AS MATERIALIZED
        (
                SELECT
                        extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS cutDate,
                        --DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS currentMonth,
						TO_DATE('2022-11-01','YYYY-MM-DD')AS FROMDATE,
						TO_DATE('2022-12-31','YYYY-MM-DD')AS TODATE,
                        c.ID AS center_id
                FROM
                        CENTERS c
                WHERE
                        c.country = 'PT'
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY",
				pag.creditor_id
        FROM payment_request_specifications prs
        JOIN params par
                ON par.center_id = prs.center
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
                AND pr.request_type = 1
                AND pr.state NOT IN (1,2,3,4,8,12,18)
        JOIN payment_accounts pac
                ON pac.center = ar.center
                AND pac.id = ar.id
        JOIN payment_agreements pag
                ON pag.center = pac.active_agr_center
                AND pag.id = pac.active_agr_id
                AND pag.subid = pac.active_agr_subid
        JOIN vivagym.clearinghouses ch
                ON ch.id = pag.clearinghouse
        WHERE
                par.cutDate = (:day)  -- Day when the reprensentation wants to be executed, regardless of the payment cycle (deduction day) the member has
                AND ar.balance < 0
                AND ar.ar_type = 4
                AND p.sex != 'C'
                AND prs.open_amount > 0
                 AND pr.req_date BETWEEN par.FROMDATE AND PAR.TODATE
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
                                 HAVING
                                COUNT(*) >= 3
                )
                AND pr.clearinghouse_id IN (401,601,1401,1402,1602,2001,1803,2202,2401,2204,2205,2002,2207,2603,2208,1202,1601,1801,2201,1802,1804,2203,2402,2206,1403,2403,1203,2601,2602)
                AND pag.state = 4
                AND pr.center IN (:center) 
) t1
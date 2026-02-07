SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                       DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                       extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                       id AS center_id
                FROM vivagym.centers c
                WHERE
                        c.country = 'ES'
						AND c.id IN (:Scope)
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY",
				pr.req_date
        FROM vivagym.payment_request_specifications prs
        JOIN params par
                ON par.center_id = prs.center
        JOIN vivagym.account_receivables ar
                ON ar.center = prs.center 
                AND ar.id = prs.id
        JOIN vivagym.persons p
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid
        JOIN vivagym.payment_requests pr
                ON prs.center = pr.inv_coll_center
                AND prs.id = pr.inv_coll_id
                AND prs.subid = pr.inv_coll_subid
                AND pr.request_type = 1
                AND pr.state NOT IN (1,2,3,4,8,12,18)
		-- Se pueden filtrar motivos de devolucion para la representacion
                --AND pr.REJECTED_REASON_CODE IN ('AM04','MS02','MS03','MD06')
        JOIN payment_agreements pag
                ON pag.center = pr.center
                AND pag.id = pr.id
                AND pag.subid = pr.agr_subid
        LEFT JOIN vivagym.payment_requests rep_req
                ON rep_req.inv_coll_center = prs.center
                AND rep_req.inv_coll_id = prs.id
                AND rep_req.inv_coll_subid = prs.subid
                AND rep_req.request_type = 6
                AND rep_req.state NOT IN (8)
        WHERE
                pr.req_date > par.cutdate
                --AND par.executionDate = 15 -- Execution Date.
		AND pr.clearinghouse_id in (201,3001,2801,3401,3801,3802,4401,4801,5001,4403,5401,5601,5801,6001,6201,7602) -- SEPA
                AND ar.balance < 0
                AND ar.ar_type = 4
                AND rep_req.center IS NULL -- exclude already represented requests
                AND p.sex != 'C'
                AND prs.open_amount > 0        
                AND pag.state = 4
) t1
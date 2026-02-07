SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                       DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                       id AS center_id
                FROM vivagym.centers c
                WHERE
                        c.country = 'ES'
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY",
                pr.REJECTED_REASON_CODE,
                ar.balance,
                prs.original_due_date,
                prs.requested_amount,
                prs.rejection_fee,
                prs.open_amount
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
        JOIN vivagym.payment_accounts pac 
                ON pac.center = ar.center
                AND pac.id = ar.id
        JOIN vivagym.payment_agreements pag
                ON pag.center = pac.active_agr_center
                AND pag.id = pac.active_agr_id
                AND pag.subid = pac.active_agr_subid
        LEFT JOIN vivagym.payment_requests rep_req
                ON rep_req.inv_coll_center = prs.center
                AND rep_req.inv_coll_id = prs.id
                AND rep_req.inv_coll_subid = prs.subid
                AND rep_req.request_type = 6
                AND rep_req.state NOT IN (8)
        WHERE
                pr.req_date > par.cutdate
				AND pr.clearinghouse_id = 201 -- SEPA
                AND ar.balance < 0
                AND ar.ar_type = 4
                -- exclude already represented requests
                AND rep_req.center IS NULL
                AND p.sex != 'C'
                AND prs.open_amount > 0        
                AND pag.state = 4
) t1
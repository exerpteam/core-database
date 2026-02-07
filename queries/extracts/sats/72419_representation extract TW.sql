SELECT
    t1.*
FROM
    (

		WITH
		params AS
		(
			SELECT
				/*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS cutDate,
				c.ID                                       AS CenterID
			FROM
				CENTERS c
		)
        SELECT
            pr.center,
            pr.id,
            pr.subid,
            p.center || 'p' || p.id AS "PERSONKEY"
        FROM
            payment_request_specifications prs
        JOIN
            params
        ON
            params.CenterID = prs.center
        JOIN
            account_receivables ar
        ON
            ar.center = prs.center
            AND ar.id = prs.id
        JOIN
            persons p
        ON
            p.center = ar.customercenter
            AND p.id = ar.customerid
        JOIN
            payment_requests pr
        ON
            prs.center = pr.inv_coll_center
            AND prs.id = pr.inv_coll_id
            AND prs.subid = pr.inv_coll_subid
            AND pr.request_type = 1
            AND pr.state NOT IN (1,2,3,4,8,12,18)
        JOIN
            payment_accounts pac
        ON
            pac.center = ar.center
            AND pac.id = ar.id
        JOIN
            payment_agreements pag
        ON
            pag.center = pac.active_agr_center
            AND pag.id = pac.active_agr_id
            AND pag.subid = pac.active_agr_subid
        WHERE
            pr.req_date >= params.cutDate - 30
            AND ar.balance < 0
            AND ar.ar_type = 4
            AND p.sex != 'C'
            AND prs.open_amount > 0
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
                    COUNT(*) >= 3 )
            AND pr.clearinghouse_id IN (3412,
                                        3413,
                                        3414,
                                        3415,
                                        3416,
                                        3417)
            AND pag.state = 4
            AND pr.xfr_info IN ('Not enough balance',
                                'Refused',
                                'Issuer Unavailable',
                                'Pin tries exceeded',
                                'Transaction Not Permitted',
                                'Withdrawal amount exceeded',
                                'Withdrawal count exceeded',
                                'Acquirer Error',
                                'Declined Non Generic',
				'Expired Card')
            AND pr.center IN (:center) 
) t1
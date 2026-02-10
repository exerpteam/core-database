-- The extract is extracted from Exerp on 2026-02-08
-- Testing the creation of accounting records for Altafit
WITH params AS MATERIALIZED
(
        SELECT
                d2.fromDate,
                d2.toDate,
                d2.center_id,
                d2.center_name
                
        FROM
        (
                SELECT
                        DATE '2025-03-01' AS fromDate,
                        DATE '2025-03-31' AS toDate,
                        d1.center_id,
                        d1.center_name
                FROM    
                (
                        SELECT
                                EXTRACT(DAY FROM TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS current_day,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS firstMonth,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + interval '1 month') - interval '1 day' AS endMonth,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day') AS firstPreviousMonth,
                                TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day' AS endPreviousMonth,
                                c.id AS center_id,
                                c.name AS center_name
                        FROM 
                                vivagym.centers c
                        WHERE
                                c.country = 'ES'
                ) d1
        ) d2
)
SELECT 
	MAX (r3.todate) AS fecha_cobro,
	r3.center AS centro,
	'43006001' AS forma_de_pago,
	SUM(r3.total_banco) AS importe,
	r3.clearinghouse_id AS clearing_house
FROM 
(
	SELECT
			r1.todate,
			r1.center,
			/*
					All the PR that was sent for collection (not sent to bank excluded) - All reclaims
			*/   
			(CASE
					-- r1.state = 2 SENT is a special case
					WHEN r1.Sent_status = 'Transaction sent to bank' THEN r1.req_amount
					ELSE 0
			END) AS total_banco,
			r1.clearinghouse_id
	FROM
	(
			SELECT
					par.toDate,
					pr.center,
					pr.req_amount,
					(CASE
							WHEN pr.state = 2 THEN 'Transaction sent to bank'
							WHEN pr.request_type = 1 AND pr.reject_fee_invline_center IS NOT NULL THEN 'Transaction sent to bank'
							WHEN pr.xfr_date IS NULL THEN 'Transaction NOT sent to bank'
							ELSE 'Transaction sent to bank'
					END) Sent_status,
					pr.clearinghouse_id
			FROM vivagym.payment_requests pr
			JOIN params par
					ON par.center_id = pr.center
			JOIN vivagym.account_receivables ar 
					ON ar.center = pr.center AND ar.id = pr.id
			JOIN vivagym.clearinghouses 
					ON pr.clearinghouse_id = vivagym.clearinghouses.id AND vivagym.clearinghouses.ctype = 185 /* 185 means SEPA */
			WHERE
					pr.req_date >= par.fromDate
					AND pr.req_date <= par.toDate
					AND pr.req_amount != 0
	) r1
	UNION ALL
	SELECT
    r2.todate,
    r2.center,
    -(r2.req_amount) as total_banco,
    r2.clearinghouse_id
	FROM
	(
		SELECT
			r1.fromDate as todate,
			r1.center,
			r1.req_amount,
			r1.clearinghouse_id,
			rank() over (partition BY r1.inv_coll_center, r1.inv_coll_id, r1.inv_coll_subid ORDER BY r1.req_date DESC) ranking
		FROM
		(
			SELECT
				par.fromDate,
				par.toDate,
				pr.center,
				pr.req_amount,
				pr.req_date,
				pr.inv_coll_center,
				pr.inv_coll_id,
				pr.inv_coll_subid,
				pr.clearinghouse_id
			FROM vivagym.clearing_in ci
			JOIN vivagym.payment_requests pr 
				ON ci.id = pr.xfr_delivery
			JOIN PARAMS par 
				ON par.center_id = pr.center
			JOIN vivagym.account_receivables ar 
				ON ar.center = pr.center AND ar.ID = pr.ID
			JOIN vivagym.clearinghouses 
				ON pr.clearinghouse_id = vivagym.clearinghouses.id AND vivagym.clearinghouses.ctype = 185 /* 185 means SEPA */
			WHERE 
				ci.received_date >= par.fromDate
			  AND ci.received_date <= par.toDate
		) r1 
	) r2
) r3
GROUP BY 
	r3.center,
	r3.clearinghouse_id

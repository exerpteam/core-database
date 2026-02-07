WITH params AS
(
    SELECT 
           TO_DATE(:from,'YYYY-MM-DD') AS fromDate,
	       TO_DATE(:to,'YYYY-MM-DD') AS toDate,
	       c.id AS center_id,
	       c.name AS center_name
	FROM
	       centers c
	WHERE
		   c.id in (:Scope)
)
SELECT
    pr.center AS center,
    ce.shortname AS Center_Name,
	ar.customercenter || 'p' || ar.customerid AS person_key,
    pr.req_amount AS Amount,
    pr.req_date AS Fecha_emision,
	ci.received_date AS fecha_importacion,
    ci.id AS File_id,
    ci.filename AS File_name,
    pr.creditor_id,
	CASE
                WHEN pr.state IN (1,12)
                THEN 'Transaction NOT sent to bank'
                ELSE 'Transaction sent to bank '
            END Sent_status
FROM vivagym.clearing_in ci
JOIN PAYMENT_REQUESTS pr
         ON ci.id = pr.xfr_delivery     
JOIN params par 
		ON par.center_id = pr.center
JOIN ACCOUNT_RECEIVABLES ar
		ON ar.center = pr.center AND ar.ID = pr.ID
JOIN vivagym.centers ce
        ON pr.center = ce.id
WHERE 
	ci.received_date  >= par.fromDate
	AND ci.received_date  <= par.toDate
	AND pr.clearinghouse_id IN (201,2801,3001,3401,3802,3801,4401,4801,5001,4403,5401,5601,5801,6001,6201,7602)
UNION
SELECT
pr.center AS center,
    ce.shortname AS Center_Name,
ar.customercenter || 'p' || ar.customerid AS person_key,
    pr.req_amount AS Amount,
    pr.req_date AS Fecha_emision,
	pr.req_date AS fecha_importacion,
    0 AS File_id,
    'Adyen rejection' AS File_name,
    pr.creditor_id,
CASE
                WHEN pr.state IN (1,8,12,19)
                THEN 'Transaction NOT sent to bank'
                ELSE 'Transaction sent to bank '
            END Sent_status
FROM
	PAYMENT_REQUESTS pr
JOIN
	PARAMS par ON par.center_id = pr.center
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
	AND ar.ID = pr.ID
JOIN
        vivagym.centers ce
        ON pr.center = ce.id
	
WHERE 
	pr.req_date  >= par.fromDate
	AND pr.req_date  <= par.toDate
 	AND pr.clearinghouse_id IN (1,3201,3002,3601,3803,4001,4201,4601,5201,4402,7402)
	AND pr.state NOT IN (3)
	AND pr.request_type = 1

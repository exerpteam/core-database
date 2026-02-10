-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
        SELECT 
                TO_DATE(:fromDate,'YYYY-MM-DD') AS fromDate,
                TO_DATE(:toDate,'YYYY-MM-DD') AS toDate,
                c.id AS center_id,
                c.name AS center_name
	FROM centers c
	WHERE 
	       c.country = 'ES'
	       AND c.id in (:Scope)
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
        pr.creditor_id
FROM vivagym.clearing_in ci
LEFT JOIN PAYMENT_REQUESTS pr
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
	AND pr.clearinghouse_id IN (7601,7001,7201,7401,5801,7202,6601,5601,6201,6801,6001)
        AND ci.total_amount <> 0

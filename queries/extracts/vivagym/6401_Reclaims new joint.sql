-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
        SELECT 
               TO_DATE(:from,'YYYY-MM-DD') AS fromDate,
	       TO_DATE(:to,'YYYY-MM-DD') AS toDate,
	       c.id AS center_id,
	       c.name AS center_name
	FROM
	       centers c
	

)

SELECT
    --ar.*,
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
FROM
        vivagym.clearing_in ci
JOIN
         PAYMENT_REQUESTS pr
         ON ci.id = pr.xfr_delivery
         
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

WHERE ci.received_date  >= par.fromDate
AND ci.received_date  <= par.toDate
--AND pr.state = 4
AND pr.creditor_id LIKE '2768'
UNION
SELECT distinct
pr.center AS center,
    ce.shortname AS Center_Name,
ar.customercenter || 'p' || ar.customerid AS person_key,
    pr.req_amount AS Amount,
    pr.req_date AS Fecha_emision,
	pr.req_date AS fecha_importacion,
    0 AS File_id,
    'Adyen rejection' AS File_name,
    pr.creditor_id,
   
 --   acl.*,
 --   longtodate(pa2.last_modified),
   
CASE
                WHEN pr.state IN (1,8,12,19)
                THEN 'Transaction NOT sent to bank'
                When acl.state in (4) and (acl.log_date > pr.req_date)
                then 'Transaction NOT sent to bank'
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
left JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.center = ar.center
AND pa.id = ar.id
left JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id
left JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID	

left join agreement_change_log acl
on
acl.agreement_center = pa2.center
and acl.agreement_id = pa2.id
and acl.agreement_subid = pa2.subid
and acl.log_date > pr.req_date
and acl.state = 4

left JOIN
        vivagym.centers ce
        ON pr.center = ce.id
	
WHERE pr.req_date  >= par.fromDate
AND pr.req_date  <= par.toDate
 AND pr.creditor_id = 'Adyen' AND pr.state NOT IN (3)
AND pr.request_type in (1,6)         
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
	WHERE
            c.country = 'ES'
			AND c.id IN (:Scope)
	

)
SELECT
        cp.external_id,
        pr.state,
        pr.center                                 AS center,
        ce.shortname                              AS Center_Name,
        ar.customercenter || 'p' || ar.customerid AS person_key,
        ROUND(pr.req_amount,2)                    AS Amount,
        pr.req_date                               AS Fecha_emision,
        pr.req_date                               AS fecha_importacion,
        0                                         AS File_id,
        'Adyen rejection'                         AS File_name,
        pr.creditor_id,
        CASE
                WHEN pr.state IN (1,7,8,12,19)
                THEN 'Transaction NOT sent to bank'
                ELSE 'Transaction sent to bank '
        END Sent_status,
        pr.state,
        pr.request_type,
        pr.xfr_date,
        pr.xfr_delivery,
        pr.xfr_info,
        pr.rejected_reason_code
FROM PAYMENT_REQUESTS pr
JOIN PARAMS par
        ON par.center_id = pr.center
JOIN ACCOUNT_RECEIVABLES ar
        ON ar.center = pr.center
        AND ar.ID = pr.ID
JOIN persons per
        ON per.center = ar.customercenter
        AND per.id = ar.customerid
JOIN persons cp
        ON per.current_person_center = cp.center
        AND per.current_person_id = cp.id
JOIN vivagym.centers ce
        ON pr.center = ce.id
WHERE
        pr.req_date >= par.fromDate
        AND pr.req_date <= par.toDate
        AND pr.creditor_id = 'Adyen'
        AND pr.state NOT IN (3)
        AND pr.request_type IN (1,6) 
        AND pr.state NOT IN (1,17)
        AND pr.rejected_reason_code IS NOT NULL 
        AND pr.rejected_reason_code NOT IN ('422')
        AND (pr.xfr_info,pr.rejected_reason_code) NOT IN (('PS_DONE_MANUAL','No Cardholder Authorisation'),
                                                          ('PS_DONE_MANUAL','Other Fraud-Card Absent Environment'),
                                                          ('PS_DONE_MANUAL','Cancelled Recurring'),
                                                          ('PS_DONE_PARTIAL','No Cardholder Authorisation'),
                                                          ('PS_DONE_PARTIAL','Other Fraud-Card Absent Environment'),
                                                          ('PS_DONE_PARTIAL','Cancelled Recurring'))

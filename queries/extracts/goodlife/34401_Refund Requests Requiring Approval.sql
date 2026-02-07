WITH RECURSIVE province (center,area) AS (

    SELECT
    
    c.id AS center
    ,ac.area AS area

    FROM
    
    centers c
    
    JOIN area_centers ac
    ON c.id = ac.center
       
    UNION
    
    SELECT
    
    p.center
    ,a.parent AS area
    
    FROM
    
    province p
    
    JOIN areas a
    ON p.area = a.id
    

),city_and_province AS (

	SELECT

	a.id AS province_id
	,a.name AS province
	,a2.id AS city_id
	,a2.name AS city
	,c.id AS center_id
	,c.name AS Center

	FROM

	province p

	JOIN areas a
	ON p.area = a.id
	AND (
		a.id BETWEEN 3 AND 11
		OR a.id = 220
	)

	JOIN centers c
	ON c.id = p.center

	JOIN province p2
	ON p2.center = c.id

	JOIN areas a2
	ON a2.id = p2.area
	AND (
		a2.parent BETWEEN 3 AND 11 
		OR a2.id = 220 -- Quebec
	)
	
)

SELECT

prs.ref AS "Invoice Id"
,p.center||'p'||p.id AS "Customer Id"
,p.fullname AS "Name"
,pr.req_amount AS "Req Amount"
,prs.open_amount AS "Open Amount"
,pr.req_date AS "Deduction day"
,pr.due_date AS "Due date"
,pr.center||'ar'||pr.id AS "Account Rec"
,pr.employee_center || 'emp' || pr.employee_id AS "EmployeeID"
,pe.fullname AS "EmployeeName"
,TO_CHAR(LONGTODATEC(prs.entry_time,prs.center),'YYYY-MM-DD HH24:MI:SS') AS "Creation Date/Time"

,CASE 
	WHEN pag.state = 1 THEN 'Created'
	WHEN pag.state = 2 THEN 'Sent'
	WHEN pag.state = 4 THEN 'OK'
	ELSE 'Other'
	END AS "Payment Agreement State (Default)"
/*
,CASE 
	WHEN pag2.state = 1 THEN 'Created'
	WHEN pag2.state = 2 THEN 'Sent'
	WHEN pag2.state = 4 THEN 'OK'
	ELSE 'Other'
	END AS "Payment Agreement State (Linked to Refund)"
*/
,c.center
,c.city
,c.province

FROM

payment_requests pr

JOIN payment_request_specifications prs
ON prs.center = pr.inv_coll_center
AND prs.id = pr.inv_coll_id
AND prs.subid = pr.inv_coll_subid
AND pr.state = 20 -- Requires Approval

JOIN account_receivables ar
ON ar.center = pr.center
AND ar.id = pr.id
AND ar.ar_type = 4 -- Payment Account

JOIN persons p
ON ar.customercenter = p.center
AND ar.customerid = p.id

JOIN city_and_province c
ON c.center_id = ar.center

JOIN payment_accounts pac
ON pac.center = pr.center
AND pac.id = pr.id

JOIN payment_agreements pag
ON pac.active_agr_center = pag.center
AND pac.active_agr_id = pag.id
AND pac.active_agr_subid = pag.subid
/*
JOIN payment_agreements pag2
ON pag2.center = pr.center
AND pag2.id = pr.id
AND pag2.subid = pr.agr_subid
*/
JOIN employees e
ON pr.employee_id = e.id
AND pr.employee_center = e.center
JOIN persons pe
ON pe.id = e.personid
AND pe.center = e.personcenter
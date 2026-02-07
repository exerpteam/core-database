WITH cashcollaggregate AS
(
SELECT MAX(startdate) AS MaxStartDate, personcenter, personid
FROM cashcollectioncases
WHERE missingpayment = 1
GROUP BY personcenter, personid
)
, cashc AS
(
SELECT ccc.personcenter, ccc.personid, ccc.currentstep, ccc.currentstep_date, ccc.startdate, ccc.nextstep_date, ccc.Closed
FROM cashcollectioncases ccc
	JOIN cashcollaggregate d
		ON d.personcenter = ccc.personcenter
		AND d.personid = ccc.personid
		AND d.maxstartdate = ccc.startdate
WHERE ccc.missingpayment=1
)

SELECT

  pr.employee_center || 'emp' || pr.employee_id AS EmployeeID
, ep.center || 'p' || ep.id AS EmployeePersonID
, ep.firstname || ' ' || ep.lastname AS EmployeeName
, p.center || 'p' || p.id As PersonID
, pr.req_amount
, pr.req_date
, TO_CHAR(longtodateC(pr.entry_time, 100), 'YYYY-MM-dd HH24:MI') AS EntryTime
, pr.xfr_info AS Info
, pr.creditor_id

, cashc.currentstep As DebtCaseCurrentStep
, cashc.currentstep_date As DebtCaseCurrentStepDate
, cashc.nextstep_date AS DebtCaseNextStepDate
, cashc.startdate AS DebtCaseStartDate
, CASE WHEN (cashc.closed = 0) THEN 'FALSE'
       WHEN (cashc.closed = 1) THEN 'TRUE'
       ELSE NULL
 END AS CLOSED



FROM PAYMENT_REQUESTS pr
	LEFT JOIN account_receivables ar
		ON ar.center = pr.center
		AND ar.id = pr.id
	LEFT JOIN persons p
		ON ar.customercenter = p.center
		AND ar.customerid = p.id
	JOIN employees e
		ON e.center = pr.employee_center
		AND e.id = pr.employee_id
	JOIN persons ep
		ON e.personcenter = ep.center
		AND e.personid = ep.id


LEFT JOIN cashc cashc
	ON cashc.personcenter = p.center
	AND cashc.personid= p.id



WHERE pr.employee_center=990 --only home office associates
	AND pr.employee_id !=228 -- API user
	AND pr.creditor_id !='3' -- companies related

	AND pr.entry_time BETWEEN 	DatetoLongC(to_char(to_date(:Transaction_Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), pr.center) 
						AND
								DatetoLongC(to_char(to_date(:Transaction_End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), pr.center)+86399999




UNION ALL



SELECT

  crt.employeecenter || 'emp' || crt.employeeid As Employeeid
, ep.center ||'p'||ep.id as EmployeePersonid
, ep.firstname || ' ' || ep.lastname As EmployeeName
, crt.customercenter || 'p' || crt.customerid As Personid
, cr.amount As CreditCardAmount
, NULL AS req_date
, TO_CHAR(longtodateC(crt.transtime, 100), 'YYYY-MM-dd HH24:MI') As TransactionTime
, NULL AS Info
,'CreditCard' AS creditor_id

, NULL 
, NULL 
, NULL 
, NULL
, NULL

FROM creditcardtransactions cr

JOIN cashregistertransactions crt
		ON cr.gl_trans_center = crt.gltranscenter
		AND cr.gl_trans_id = crt.gltransid 
		AND cr.gl_trans_subid = crt.gltranssubid
		AND cr.amount = crt.amount


LEFT JOIN Employees e
		ON e.center = crt.employeecenter
		AND e.id = crt.employeeid

JOIN Persons ep
		ON ep.center = e.personcenter
		AND ep.id = e.personid

LEFT JOIN Persons p
		ON p.center = crt.customercenter
		AND p.id = crt.customerid

WHERE crt.center=990
	AND crt.id=3 --only MED cash register
	AND cr.amount != 0

	AND crt.transtime BETWEEN 	DatetoLongC(to_char(to_date(:Transaction_Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), crt.center) 
						AND
								DatetoLongC(to_char(to_date(:Transaction_End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), crt.center)+86399999
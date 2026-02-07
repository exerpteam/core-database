
SELECT

cr.name,
c.shortname AS "Club",
TO_CHAR(longtodate(crt.transtime), 'YYYY-MM-dd HH24:MI') AS "TransactionTime",
crt.customercenter || 'p' || crt.customerid AS "Customer",

crt.amount,
			
CASE crt.config_payment_method_id
        WHEN 0 THEN 'VouchersOld'
		WHEN 1 THEN 'PaymentLink'
        WHEN 10 THEN 'WebDebtPayment'
		WHEN 101 THEN 'Paypal'
		WHEN 5004111 THEN 'AdyenOld'
		ELSE 'Unknown'
		END AS "SpecialPaymentMethod",

CASE crt.crttype
        WHEN 0 THEN '0'
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN '2'
        WHEN 3 THEN '3'
        WHEN 4 THEN '4'
        WHEN 5 THEN 'CashAccount'
        WHEN 6 THEN '6'
        WHEN 7 THEN 'CreditCard'
        WHEN 8 THEN '8'
        WHEN 9 THEN '9'
		WHEN 10 THEN '10'
		WHEN 11 THEN '11'
		WHEN 12 THEN 'PaymetAccount'
		WHEN 13 THEN 'Other'
		WHEN 14 THEN '14'
		WHEN 15 THEN '15'
		WHEN 16 THEN '16'
		WHEN 17 THEN '17'
		WHEN 18 THEN 'MemberCashOut'
		WHEN 19 THEN '19'
        WHEN 20 THEN 'CC Adjustment'
		ELSE 'unknown'
    END AS "TransType",
CRT.employeecenter || 'p' || crt.employeeid AS "EmployeID",
P.Fullname AS CustomerName,
crt.artransid AS "ArtTransId"


FROM
centers c

JOIN
cashregisters cr
ON cr.center=c.id

JOIN

cashregistertransactions crt
ON cr.id = crt.crid
AND cr.center = crt.center

LEFT JOIN
Persons P
ON  crt.customercenter=P.center
AND crt.customerid = P.ID


WHERE
---cr.name IN ('WEB') AND---
cr.center IN ( :scope)
AND
TO_CHAR(longtodate(crt.transtime), 'YYYY-MM-DD')>=:From
AND
TO_CHAR(longtodate(crt.transtime), 'YYYY-MM-DD')<=:To

ORDER BY
c.shortname,
cr.name

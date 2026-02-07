/**
* Creator: Exerp
* Purpose: List AgreementTransactions made for persons with companies as payers.
*/
SELECT
    person.CENTER || 'p' || person.id AS Personid,    
    person.fullname AS "Member Name",
    company.CENTER || 'p' || company.id AS Companyid,
    company.LASTNAME AS Company,
	ca.center || 'p' || ca.id || 'rpt' || ca.subid AS "company agreement id",
	ca.name AS "Company agreement",
	pr.req_amount AS "Payment request amount",
	pr.req_date AS "Deduction date"
FROM
    PERSONS person
LEFT JOIN RELATIVES rel
ON
    person.CENTER = rel.RELATIVECENTER
    AND person.ID = rel.RELATIVEID
    AND rel.RTYPE = 2
LEFT JOIN PERSONS company
ON
    company.CENTER = rel.CENTER
    AND company.ID = rel.ID
JOIN
	relatives rel2
ON 
	rel2.center = person.center 
	AND rel2.id = person.id
	AND	rel2.RTYPE = 3 

LEFT JOIN
	COMPANYAGREEMENTS ca
ON
	ca.CENTER = rel2.RELATIVECENTER
    AND ca.ID = rel2.RELATIVEID
	AND ca.subid = rel2.RELATIVESUBID

JOIN
	ACCOUNT_RECEIVABLES ar
ON 
	ar.CUSTOMERCENTER = person.center
AND
	ar.CUSTOMERID = person.id

JOIN
	PAYMENT_REQUESTS pr
ON
    pr.center = ar.center
    AND pr.id = ar.id

WHERE
	pr.REQ_DATE BETWEEN (:from_date) AND (:to_date)
	AND company.CENTER IN (:scope)

AND
	rel.status = (1)
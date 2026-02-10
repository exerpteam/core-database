-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    CUSTOMERCENTER ||'p'|| CUSTOMERID as memberid,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
	DECODE(AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') as AR_TYPE,
    BALANCE,
	PERSONS.EXTERNAL_ID
FROM
    ACCOUNT_RECEIVABLES
JOIN
    persons
ON
    ACCOUNT_RECEIVABLES.customercenter = PERSONS.center
    AND ACCOUNT_RECEIVABLES.customerid=PERSONS.id
WHERE
    BALANCE != 0
    And Persons.center in (:scope)
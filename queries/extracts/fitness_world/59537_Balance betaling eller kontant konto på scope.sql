-- This is the version from 2026-02-05
--  
SELECT
    CUSTOMERCENTER ||'p'|| CUSTOMERID as memberid,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
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
    ACCOUNT_RECEIVABLES.AR_TYPE = :Kontotype
    AND BALANCE > :MoreThan
    AND BALANCE < :LessThan
    And Persons.center in (:scope)
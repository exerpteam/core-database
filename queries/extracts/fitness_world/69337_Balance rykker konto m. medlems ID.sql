-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    CUSTOMERCENTER ||'p'|| CUSTOMERID as memberid,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
    BALANCE
FROM
    ACCOUNT_RECEIVABLES
JOIN
    persons
ON
    ACCOUNT_RECEIVABLES.customercenter = PERSONS.center
    AND ACCOUNT_RECEIVABLES.customerid=PERSONS.id
WHERE
    ACCOUNT_RECEIVABLES.AR_TYPE = 5
    AND BALANCE <= 0
 	AND (Persons.center,persons.id) in (:memberid)

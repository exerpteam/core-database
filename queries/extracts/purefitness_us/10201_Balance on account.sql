 SELECT
     CUSTOMERCENTER ||'p' || CUSTOMERID as memberid,
     PERSONS.firstname,
     PERSONS.lastname,
     BALANCE
 FROM
     ACCOUNT_RECEIVABLES 
 JOIN
     persons
 ON
     ACCOUNT_RECEIVABLES.customercenter = PERSONS.center
     AND ACCOUNT_RECEIVABLES.customerid=PERSONS.id
 WHERE
     ACCOUNT_RECEIVABLES.CENTER in (:scope)
     AND ACCOUNT_RECEIVABLES.AR_TYPE = :Accounttype
AND BALANCE != 0
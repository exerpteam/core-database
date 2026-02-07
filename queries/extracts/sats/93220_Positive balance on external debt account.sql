 SELECT
     ar.CUSTOMERCENTER ||'p' || ar.CUSTOMERID as memberid,
     ar.balance
 FROM
     ACCOUNT_RECEIVABLES ar
 JOIN
     persons p
 ON
     ar.customercenter = p.center
     AND ar.customerid = p.id
 WHERE
     ar.center in (:scope)
     AND ar.ar_type = 5
     AND ar.balance > 0

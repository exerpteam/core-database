 SELECT
     ar.CUSTOMERCENTER ||'p' || ar.CUSTOMERID as memberid,
     p.firstname as firstname,
     p.lastname as lastname,
     p.STATUS as status,
     ar.BALANCE as balance
 FROM
     ACCOUNT_RECEIVABLES ar
 JOIN
     persons p
 ON
     ar.customercenter = p.center
     AND ar.customerid = p.id
 WHERE
     ar.CENTER in (:scope)
     AND ar.AR_TYPE = (:Kontotype)
     and (p.center, p.id) in (:memberid)

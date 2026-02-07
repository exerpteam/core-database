 Select
 ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID,
 ar.BALANCE
 from
 ACCOUNT_RECEIVABLES ar
 where (ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID) in (:memberid)
 and ar.AR_TYPE = 4
 and ar.BALANCE != 0
 order by ar.BALANCE

-- This is the version from 2026-02-05
--  
Select
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID,
at.text, 
at.amount,
TO_CHAR(TRUNC(longtodate(at.ENTRY_TIME)), 'dd-mm-yyyy') as entrytime
from AR_TRANS at

join ACCOUNT_RECEIVABLES ar
on
at.center = ar.center
and
at.id = ar.id

where
(ar.CUSTOMERCENTER, ar.customerid) in (:scope)

and
at.TRANS_TIME BETWEEN :time_from AND :time_to+(24*3600*1000)

and 
ar.ar_type = 5
and
at.text = 'Transfer between accounts'

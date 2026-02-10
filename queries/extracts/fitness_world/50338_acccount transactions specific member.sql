-- The extract is extracted from Exerp on 2026-02-08
--  
Select
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID,
at.text, 
at.amount,
eclub2.longToDate(at.TRANS_TIME)
from AR_TRANS at

left join ACCOUNT_RECEIVABLES ar
on
at.center = ar.center
and
at.id = at.id

where
ar.CUSTOMERCENTER = 103
and
ar.CUSTOMERID = 2980
and
at.TRANS_TIME BETWEEN :time_from AND :time_to+(24*3600*1000)
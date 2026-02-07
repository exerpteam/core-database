-- This is the version from 2026-02-05
--  
select
cc.AMOUNT,
cc.CC_AGENCY_AMOUNT,
ar.CUSTOMERCENTER ||'p'||ar.CUSTOMERID as "person key"

from 
CASHCOLLECTIONCASES cc

join
ACCOUNT_RECEIVABLES ar
on
ar.center = cc.AR_CENTER
and
ar.id = cc.AR_ID

where
cc.AMOUNT not = cc.CC_AGENCY_AMOUNT

and 

ar.CUSTOMERCENTER in($$scope$$)
-- The extract is extracted from Exerp on 2026-02-08
--  
select ar.CUSTOMERCENTER, longtodate(max(pag.CREATION_TIME)) as LatestAgreementCreation, count(*)
from FW.PAYMENT_AGREEMENTS pag
join FW.ACCOUNT_RECEIVABLES ar on ar.center = pag.center and ar.id = pag.id
where 
pag.CREDITOR_ID = 'FW Baron Bolten'
and pag.CREATION_TIME >= datetolong('2014-07-07 00:00')
group by ar.CUSTOMERCENTER
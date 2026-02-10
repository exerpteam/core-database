-- The extract is extracted from Exerp on 2026-02-08
--  
select 
  art.center As Center
, TO_CHAR(longtodateC(art.trans_time, 100), 'YYYY-MM-dd HH24:MI') As TransactionTime
,split_part(art.info,'||',1) AS OrderNumber
 ,split_part(art.info,'||',2) AS Transaction_No
, substring(art.info from 8 for 10) AS InvoiceNumber
, ar.customercenter || 'p' || ar.customerid As Customerid
, p.firstname || ' ' || p.lastname As CustomerName
, art.employeecenter || 'emp' || art.employeeid As Employeeid
, ep.firstname || ' ' || ep.lastname As EmployeeName
, art.amount As Amount
, acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id As AggregatedTransactionId

from ar_trans art

join account_receivables ar
	on art.center = ar.center
	and art.id = ar.id
		
join account_trans acct
	on art.ref_center = acct.center
	and art.ref_id = acct.id
	and art.ref_subid = acct.subid
	
join Employees e
	on e.center = art.employeecenter
	and e.id = art.employeeid

join Persons ep
	on ep.center = e.personcenter
	and ep.id = e.personid

join Persons p
	on p.center = ar.customercenter
	and p.id = ar.customerid

where art.trans_time BETWEEN
		CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000+18000000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000+18000000

AND art.text = 'API Sale Transaction'

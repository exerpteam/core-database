select 
  crt.center As CashRegisterCenter
, crt.id As CashRegisterId
, TO_CHAR(longtodateC(crt.transtime, $$CashRegisterCenter$$), 'YYYY-MM-dd HH24:MI') As TransactionTime
, crt.artranscenter|| 'ar' || crt.artransid AS Ref
, crt.customercenter || 'p' || crt.customerid As Customerid
, p.firstname || ' ' || p.lastname As CustomerName
, crt.employeecenter || 'emp' || crt.employeeid As Employeeid
, ep.firstname || ' ' || ep.lastname As EmployeeName
, acct.amount As CreditCardAmount
, acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id As AggregatedTransactionId
--,* 

from creditcardtransactions cr

join cashregistertransactions crt
		on cr.gl_trans_center = crt.gltranscenter
		and cr.gl_trans_id = crt.gltransid 
		and cr.gl_trans_subid = crt.gltranssubid
		and cr.amount = crt.amount

join account_trans acct
		on crt.gltranscenter = acct.center
		and crt.gltransid = acct.id
		and crt.gltranssubid = acct.subid

left join Employees e
		on e.center = crt.employeecenter
		and e.id = crt.employeeid

join Persons ep
		on ep.center = e.personcenter
		and ep.id = e.personid

left join Persons p
		on p.center = crt.customercenter
		and p.id = crt.customerid

where crt.center=$$CashRegisterCenter$$
	and crt.id IN ($$CashRegisterNumber$$)

	and crt.transtime BETWEEN 	DatetoLongC(to_char(to_date(:Transaction_Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$) AND
	DatetoLongC(to_char(to_date(:Transaction_End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$)+86399999

	and acct.amount != 0


UNION ALL

--return "Member cash out" transactions from member account

select 
  crt.center As CashRegisterCenter
, crt.id As CashRegisterId
, TO_CHAR(longtodateC(crt.transtime, 100), 'YYYY-MM-dd HH24:MI') As TransactionTime
, crt.artranscenter|| 'ar' || crt.artransid AS Ref
, crt.customercenter || 'p' || crt.customerid As Customerid
, p.firstname || ' ' || p.lastname As CustomerName
, crt.employeecenter || 'emp' || crt.employeeid As Employeeid
, ep.firstname || ' ' || ep.lastname As EmployeeName
, at.amount As CreditCardAmount
, acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id As AggregatedTransactionId

from cashregistertransactions crt
	join ar_trans at
		on at.center = crt.artranscenter
		and at.id = crt.artransid
		and at.subid = crt.artranssubid
	join account_trans acct
		on crt.gltranscenter = acct.center
		and crt.gltransid = acct.id
		and crt.gltranssubid = acct.subid

left join Employees e
		on e.center = crt.employeecenter
		and e.id = crt.employeeid

join Persons ep
		on ep.center = e.personcenter
		and ep.id = e.personid

left join Persons p
		on p.center = crt.customercenter
		and p.id = crt.customerid

where crt.transtime BETWEEN 	DatetoLongC(to_char(to_date(:Transaction_Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$) AND
	DatetoLongC(to_char(to_date(:Transaction_End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$)+86399999

	and crt.center=$$CashRegisterCenter$$
	and crt.id IN ($$CashRegisterNumber$$)
	and at.text = 'Member cash out'


UNION ALL

--return "Payout of Credit Note" transactions from cash register transactions

select 
  crt.center As CashRegisterCenter
, crt.id As CashRegisterId
, TO_CHAR(longtodateC(crt.transtime, 100), 'YYYY-MM-dd HH24:MI') As TransactionTime
, acct.text AS Ref
, cn.payer_center || 'p' || cn.payer_id As Customerid
, p.firstname || ' ' || p.lastname As CustomerName
, crt.employeecenter || 'emp' || crt.employeeid As Employeeid
, ep.firstname || ' ' || ep.lastname As EmployeeName
, -crt.amount As CreditCardAmount
, acct.aggregated_transaction_center || 'agt' || acct.aggregated_transaction_id As AggregatedTransactionId

from cashregistertransactions crt
	
join account_trans acct
	on crt.gltranscenter = acct.center
	and crt.gltransid = acct.id
	and crt.gltranssubid = acct.subid
	
join credit_notes cn
	on cn.cashregister_center = crt.crcenter
	and cn.cashregister_id = crt.crid
	and cn.paysessionid = crt.paysessionid

join Employees e
	on e.center = crt.employeecenter
	and e.id = crt.employeeid

join Persons ep
	on ep.center = e.personcenter
	and ep.id = e.personid

join Persons p
	on p.center = cn.payer_center
	and p.id = cn.payer_id

where crt.transtime BETWEEN 	DatetoLongC(to_char(to_date(:Transaction_Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$) AND
	DatetoLongC(to_char(to_date(:Transaction_End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'), $$CashRegisterCenter$$)+86399999

	and crt.center=$$CashRegisterCenter$$
	and crt.id IN ($$CashRegisterNumber$$)
	and crt.crttype = '18'

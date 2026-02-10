-- The extract is extracted from Exerp on 2026-02-08
-- This extract identifies all the transactions related to cheque refunds that go into account 0012-12400-000

select 
  TO_CHAR(longtodateC(ar.trans_time, 100),'YYYY-MM-DD') AS TransactionDate
, CASE WHEN p.External_id IS NULL THEN trsf.External_id ELSE p.External_id END AS ExternalId
, 'REF E' || lpad(CASE WHEN p.External_id IS NULL THEN trsf.External_id ELSE p.External_id END,7,'0') AS VendorId
, p.center || 'p' || p.id As PersonID
, p.FullName
, p.FullName as ChequeName
, p.address1 as AddressLine1
, p.address2 as AddressLine2
, p.City
, z.Province
, p.ZipCode AS PostalCode
, acct.aggregated_transaction_center ||'agt'||acct.aggregated_transaction_id As RefundNumber
, p.center AS MemberClub
, -ar.amount as RefundAmount
, ar.Text
, CASE WHEN p.Sex = 'C' THEN 'Company' ELSE 'Individual' END as type
--, ep.External_Id as StaffExternalId
, ep.center || 'p' || ep.id As StaffPersonID
, ep.FullName as StaffName
, TO_CHAR(longtodateC(ar.entry_time, 100),'YYYY-MM-DD') AS EntryDate

from ar_trans ar
	join account_trans acct
		on acct.center = ar.ref_center
		and acct.id = ar.ref_id
		and acct.subid = ar.ref_subid
	join accounts a
		on (acct.credit_accountid = a.id and acct.credit_accountcenter = a.center)
		or (acct.debit_accountid = a.id and acct.debit_accountcenter = a.center)
    join account_receivables accr
		on accr.center = ar.center
		and accr.id = ar.id
	join persons p
		on p.center = accr.customercenter
		and p.id = accr.customerid
	left join zipcodes z
		on z.country = p.country
		and z.zipcode = p.zipcode
	join Employees emp
		on emp.center = ar.employeecenter
		and emp.id = ar.employeeid
	join Persons ep
		on ep.center = emp.personcenter
		and ep.id = emp.personid
	
	left join Persons trsf
		on CASE WHEN p.center != p.transfers_current_prs_center
 				THEN p.transfers_current_prs_center ELSE p.center END  = trsf.center
		and CASE WHEN p.id != p.transfers_current_prs_id
 				THEN p.transfers_current_prs_id ELSE p.id END  = trsf.id
	
where 
	a.external_id='0012-12400-000'
	and ar.entry_time BETWEEN
		CAST((:RefundsStartDate-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:RefundsEndDate-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000 

--and customercenter = 124
--and customerid=19001

-- The extract is extracted from Exerp on 2026-02-08
--  
select 

TO_CHAR(longtodateC(ar.entry_time, 100), 'YYYY-MM-dd HH24:MI') As EntryTime,
p.center || 'p' || p.id as PersonId,
p.firstname || ' ' || p.lastname As CustomerName,
p.External_Id,
ar.ref_center || 'inv' || ar.ref_id As InvoiceId,
ar.Status,
ar.unsettled_amount As OpenBalance,
ar.text

from ar_trans ar
join account_receivables acc
	on ar.center=acc.center
	and ar.id=acc.id
join persons p
	on p.center=acc.customercenter
	and p.id=acc.customerid


where ar.status!='CLOSED'
	and ar.center in ($$scope$$) 
	and
	CASE WHEN $$personid$$='ALL' THEN '1' ELSE
		p.center || 'p' || p.id = $$personid$$--(:personid)  
	END

and ar.entry_time BETWEEN
		CAST((:StartDate-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:EndDate-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
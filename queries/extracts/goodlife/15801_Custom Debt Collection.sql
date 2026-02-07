WITH
    PARAMS AS
    (
        SELECT
            CASE
                WHEN $$offset$$=-1
                THEN 0
                ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
            END AS FROMDATE,
            CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS TODATE
    )
    

select 
ar.center || 'tr' || ar.id  || 'ln' || ar.subid  as ID,
ar.ref_center||'acc'|| ar.ref_id || 'tr'|| ar.ref_subid as FinanceTransactionID,
TO_CHAR(longtodateC(ar.entry_time, 100), 'YYYY-MM-dd HH24:MI') As EntryTime,
p.center || 'p' || p.id as PersonId,
p.firstname || ' ' || p.lastname As CustomerName,
p.External_Id,

CASE WHEN ar.text LIKE 'PartialCreditnote%' THEN 
ar.ref_center || 'cred' || ar.ref_id
ELSE ar.ref_center || 'inv' || ar.ref_id END As InvoiceId,

--ar.ref_center || 'inv' || ar.ref_id As InvoiceId,
ar.Status,
ar.unsettled_amount As OpenBalance,
ar.text


from ar_trans ar
CROSS JOIN
    params
join account_receivables acc
	on ar.center=acc.center
	and ar.id=acc.id
join persons p
	on p.center=acc.customercenter
	and p.id=acc.customerid



where ar.status!='CLOSED'
	and ar.unsettled_amount <0
	and ar.center in ($$scope$$) 
	and ar.entry_time BETWEEN
		PARAMS.FROMDATE AND PARAMS.TODATE



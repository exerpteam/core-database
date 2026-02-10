-- The extract is extracted from Exerp on 2026-02-08
--  
select ar.customercenter  || 'p' || ar.customerid as PersonKey, pr.req_date as OriginalDeductionDate, pr.rejected_reason_code, pr.req_amount as OriginalRequestAmount, pr.xfr_date as RejectionDate, ar.balance as PaymentAccountBalance, pag.state, pag.active, TO_CHAR(longtodate(art.entry_time),'YYYY-MM-DD') as FeeApplied, art.amount as FeeAmount, art.unsettled_amount 
--select art.center, art.id, art.subid
from goodlife.ar_trans art
join goodlife.account_receivables ar on ar.center = art.center and ar.id = art.id
join goodlife.payment_request_specifications prs on prs.center = art.payreq_spec_center and prs.id = art.payreq_spec_id and prs.subid = art.payreq_spec_subid
join goodlife.payment_requests pr on pr.inv_coll_center = prs.center and pr.inv_coll_id = prs.id and pr.inv_coll_subid = prs.subid and pr.request_type = 1
left join goodlife.payment_requests rpr on rpr.inv_coll_center = prs.center and rpr.inv_coll_id = prs.id and rpr.inv_coll_subid = prs.subid and rpr.request_type = 6
left join goodlife.payment_accounts pac on pac.center = ar.center and pac.id = ar.id
left join goodlife.payment_agreements pag1 on (pag1.center = pr.center and pr.id = pag1.id and pag1.subid = pr.agr_subid)
left join goodlife.payment_agreements pag on ((pag1.current_center is not null and pag.center = pag1.current_center and pag1.current_id = pag.id and pag.subid = pag1.current_subid)
or (pag1.current_center is null and pag.center = pag1.center and pag1.id = pag.id and pag.subid = pag1.subid))

where art.text like 'Cash collection: %'
and art.employeecenter is null
and rpr.center is null
AND pr.STATE NOT IN (1,2,3,4,8,12)
AND pr.REJECTED_REASON_CODE in ('01','08')
AND (pag.state = 4 or pag.active = false)
AND art.unsettled_amount < 0
AND art.center in (:scope)
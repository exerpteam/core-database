-- The extract is extracted from Exerp on 2026-02-08
-- see https://goodlifefitness.atlassian.net/wiki/spaces/ITS/pages/3063283727/Exerp+-+First+of+Month+Accounting+Billing+Issue

SELECT


c.name AS center
,prov.name AS province
,ar.customercenter||'p'||ar.customerid AS personid
,pr.req_date
,pr.req_amount
,prs.ref AS payment_request_ref
,CASE
	WHEN pr.state = 1
	THEN 'NEW'
	WHEN pr.state = 2
	THEN 'SENT'
	WHEN pr.state = 3
	THEN 'DONE'
	WHEN pr.state = 4
	THEN 'DONE - MANUAL'
	WHEN pr.state = 17
	THEN 'REVOKED'
	ELSE 'OTHER'
END AS payment_request_state
,co.id AS export_file_id
,TO_CHAR(longtodateC(pay.entry_time, pay.center),'YYYY-MM-DD HH24:MI:SS') AS payment_entry_time


,rp.id AS reporting_period_id
,rp.period_name AS reporting_period_name
,CASE
	WHEN rp.hard_close_time IS NOT NULL
	THEN TO_CHAR(longtodateC(rp.hard_close_time, '990'),'YYYY-MM-DD HH24:MI:SS') 
ELSE ''
END AS hard_close_time


FROM

payment_requests pr

JOIN clearing_out co
ON pr.req_delivery = co.id

JOIN payment_request_specifications prs
ON pr.inv_coll_center = prs.center
AND pr.inv_coll_id = prs.id
AND pr.inv_coll_subid = prs.subid

JOIN account_receivables ar
ON ar.center = pr.center
AND ar.id = pr.id

JOIN area_centers ac
ON ac.center = pr.center

JOIN areas a
ON ac.area = a.id
AND a.root_area = 1 -- System
-- AND a.parent IN (6,7,8,10) -- NB, NL, NS, PE

JOIN areas prov
ON prov.id = a.parent

JOIN centers c
ON pr.center = c.id

JOIN ar_trans art
ON art.payreq_spec_center = prs.center
AND art.payreq_spec_id = prs.id
AND art.payreq_spec_subid = prs.subid
AND art.trans_time < CAST((:EntryStartTime-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 


JOIN report_periods rp
ON art.trans_time BETWEEN
datetolongTZ(TO_CHAR(rp.start_date,'YYYY-MM-DD HH24:MI:SS'), c.time_zone)
AND datetolongTZ(TO_CHAR(rp.end_date,'YYYY-MM-DD HH24:MI:SS'), c.time_zone) 

LEFT JOIN ar_trans pay
ON pay.center = art.center
AND pay.id = art.id
AND pay.payreq_spec_center = prs.center
AND pay.payreq_spec_id = prs.id
AND pay.payreq_spec_subid = prs.subid
AND pay.collected = 2 -- Payment
AND pay.ref_type = 'ACCOUNT_TRANS'
AND pay.trans_time > CAST((:EntryStartTime-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 

WHERE

pr.employee_center IS NOT NULL
AND pr.request_type = 1 -- Payment
AND co.generated_date >= :EntryStartTime

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
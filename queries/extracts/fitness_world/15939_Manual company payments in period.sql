-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS customerID,
	p.lastname as company_name, 
    act.amount,
    act.text as request_text,
--    act.info,
    longtodate(act.entry_time) as payment_time
FROM
     fw.AR_TRANS art
JOIN fw.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
AND ar.ID = art.ID
JOIN fw.ACCOUNT_TRANS act
ON
    act.CENTER = art.REF_CENTER
AND act.id = art.REF_ID
AND act.SUBID = art.REF_SUBID
AND art.REF_TYPE = 'ACCOUNT_TRANS'
join fw.persons p
  on
    ar.CUSTOMERCENTER = p.center
    and ar.CUSTOMERID = p.id
    and p.sex like 'C'
WHERE
     ar.CUSTOMERCENTER in (:scope)
and act.entry_time >= (:from_date)
and act.entry_time <= (:to_date) + 86400000 
and ar.AR_TYPE = 4
AND act.info_type = 16
order by
	ar.CUSTOMERCENTER,
	act.entry_time
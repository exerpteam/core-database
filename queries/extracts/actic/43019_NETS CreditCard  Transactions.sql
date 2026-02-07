WITH
    PARAMS AS materialized
    (
        SELECT
                
				         TO_CHAR((date_trunc('month', getcentertime(100)::date) - interval '1' month), 'YYYY-MM-DD') AS periodFrom,
				TO_CHAR((date_trunc('month', getcentertime(100)::date) - interval '1' day),'YYYY-MM-DD') AS periodTo,
				datetolongTZ(TO_CHAR((date_trunc('month', getcentertime(100)::date) - interval '1' month), 'YYYY-MM-DD'),'Europe/Stockholm')::BIGINT AS periodFromLong,
				datetolongTZ(TO_CHAR((date_trunc('month', getcentertime(100)::date)),'YYYY-MM-DD HH24:MI'),'Europe/Stockholm')::BIGINT AS periodToLong,
				getcentertime(100) AS todaysDate
		
    )


select 
longtodatetz(ct.TRANSTIME,'Europe/London') AS "TransactionTime",
ct.TRANSACTION_ID AS "TRANSACTIONID",
ct.amount AS "AmountToPay",
ct.TYPE AS "Type",
iv.PAYER_CENTER ||'p'||iv.PAYER_ID AS "PersonId",
iv.TEXT AS "SOLD_ITEM"

from params
cross join CREDITCARDTRANSACTIONS ct

join CASHREGISTERTRANSACTIONS crt 
	on crt.GLTRANSCENTER = ct.GL_TRANS_CENTER and 
	crt.GLTRANSID = ct.GL_TRANS_ID and 
	crt.GLTRANSSUBID = ct.GL_TRANS_SUBID
join CASHREGISTERS ca on 
	crt.CRCENTER = ca.CENTER and 
	crt.CRID = ca.ID
join CENTERS c on 
	ca.CENTER = c.ID
left join INVOICES iv on
	iv.PAYSESSIONID = crt.PAYSESSIONID
where 
	ct.TRANSTIME BETWEEN (params.periodFromLong) AND (params.periodToLong)and
	
	--ct.TRANSTIME > $ $from_time$$ and 
	--ct.TRANSTIME < $ $to_time$$ and
	
	c.COUNTRY='SE' and
	c.id IN (:Scope)


select 
longtodatetz(ct.TRANSTIME,'Europe/London') AS "TransactionTime",
ct.TRANSACTION_ID AS "TRANSACTIONID",
ct.amount AS "AmountToPay",
ct.TYPE AS "Type",
iv.PAYER_CENTER ||'p'||iv.PAYER_ID AS "PersonId",
iv.TEXT AS "SOLD_ITEM"

FROM CREDITCARDTRANSACTIONS ct

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
	--ct.TRANSTIME BETWEEN (params.periodFromLong) AND (params.periodToLong)and
	
	ct.TRANSTIME > $$from_time$$ and 
	ct.TRANSTIME < $$to_time$$ + 3600 * 24 * 1000 and
	
	c.COUNTRY='SE' and
	c.id IN (:Scope)

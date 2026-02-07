select 

c.NAME AS "CenterName",
exerpro.longtodatetz(ct.TRANSTIME,'Europe/London') AS "TransactionTime",
ct.TRANSTIME AS "TransactionTimeInMillis",
ct.amount AS "AmountToPay",
ca.NAME AS "CashRegister"

from CREDITCARDTRANSACTIONS ct

join CASHREGISTERTRANSACTIONS crt on crt.GLTRANSCENTER = ct.GL_TRANS_CENTER and crt.GLTRANSID = ct.GL_TRANS_ID and crt.GLTRANSSUBID = ct.GL_TRANS_SUBID

join CASHREGISTERS ca on crt.CRCENTER = ca.CENTER and crt.CRID = ca.ID

join CENTERS c on ca.CENTER = c.ID

where ct.TRANSTIME > $$from_time$$ and ct.TRANSTIME < $$to_time$$ and c.COUNTRY='SE'

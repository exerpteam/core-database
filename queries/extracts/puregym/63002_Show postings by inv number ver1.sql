select
cred.external_id as creditaccount,
deb.external_id as Debitaccount,
il.text,
il.net_amount,
longtodate(act.entry_time) as entrydate,
il.PERSON_CENTER  ||'p'|| il.PERSON_ID as memberid,
il.center ||'inv'|| il.id as "payment receipt",
il.subid,
crt.paysessionid,
actv.amount as "VAT amount",
credv.external_id as "creditaccount VAT",
debv.external_id as "Debitaccount VAT",
payment.info as paymentinfo,
payment.amount as "payment amount",
credpay.external_id as "creditaccount Payment",
debpay.external_id as "Debitaccount Payment"

from
INVOICES i 

join
INVOICE_LINES_MT il
on
i.center = il.center
and
i.id = il.id

LEFT JOIN 
    CASHREGISTERTRANSACTIONS cr
ON
    cr.PAYSESSIONID = i.PAYSESSIONID
LEFT JOIN 
    CUSTOMER_INVOICE ci
ON
    ci.REFERENCE_CENTER =  i.center
    AND ci.REFERENCE_ID = i.id

join
ACCOUNT_TRANS act

on

il.ACCOUNT_TRANS_CENTER = act.center
and
il.ACCOUNT_TRANS_ID = act.id
and
il.ACCOUNT_TRANS_SUBID = act.subid

join
ACCOUNT_TRANS actv
on
act.center = actv.MAIN_TRANSCENTER
and
act.id = actv.MAIN_TRANSID
and
act.subid = actv.MAIN_TRANSSUBID

join
ACCOUNTS credv
on
actv.CREDIT_ACCOUNTID = credv.id
and
actv.CREDIT_ACCOUNTCENTER = credv.center

join
ACCOUNTS debv
on
actv.DEBIT_ACCOUNTID = debv.id
and
actv.DEBIT_ACCOUNTCENTER = debv.center

join
ACCOUNTS cred
on
act.CREDIT_ACCOUNTID = cred.id
and
act.CREDIT_ACCOUNTCENTER = cred.center

join
ACCOUNTS deb
on
act.DEBIT_ACCOUNTID = deb.id
and
act.DEBIT_ACCOUNTCENTER = deb.center

left join CASHREGISTERTRANSACTIONS crt
on
i.paysessionid = crt.paysessionid  

left join
account_trans payment
on
payment.center = crt.gltranscenter
and
payment.id = crt.gltransid
and
payment.subid = crt.gltranssubid

left join
ACCOUNTS credpay
on
payment.CREDIT_ACCOUNTID = credpay.id
and
payment.CREDIT_ACCOUNTCENTER = credpay.center

left join
ACCOUNTS debpay
on
payment.DEBIT_ACCOUNTID = debpay.id
and
payment.DEBIT_ACCOUNTCENTER = debpay.center

where

i.center = (:center)
and i.id =(:invnumber) 
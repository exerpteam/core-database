Select cc.transaction_id, longtodatec(cc.transtime, cc.center) as TransactionTime, cc.center, cc.amount
from chelseapiers.creditcardtransactions  cc
where cc.cof_payment_agreement_id is null
and cc.transaction_id is not null
order by longtodatec(cc.transtime, 13) desc
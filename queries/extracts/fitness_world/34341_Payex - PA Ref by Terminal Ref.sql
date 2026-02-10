-- The extract is extracted from Exerp on 2026-02-08
--  
select 

pr.REF as "Terminal_Ref" , 
pr.REQ_AMOUNT as "Amount_to_pay", 
pa.REF as "Payment_Agreement_REF"

from FW.PAYMENT_REQUESTS pr

join FW.PAYMENT_AGREEMENTS pa on pa.CENTER = pr.CENTER and pa.ID = pr.ID 

WHERE pr.ref IN (:refId)

group by pr.REF
Select

cr.ref as               paymentrequest,
CASE cr.STATE WHEN -1 THEN 'NOT_SENT' WHEN 0 THEN 'NEW' WHEN 1 THEN 'SENT' WHEN 2 THEN 'PAID' WHEN 3 THEN 'CANCELLED' WHEN 4 THEN 'RECEIVED' WHEN 6 THEN 'LEGACY' WHEN 7 THEN 'FAILED' ELSE 'Undefined' END AS "cash collection request STATE",
cr.REQ_AMOUNT as requestedamount,
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID as personid,
cr.REQ_DELIVERY as fileid,
cr.req_date


from cashcollection_requests cr

join cashcollection_out casho
on
casho.id = cr.req_delivery
Join
    PAYMENT_REQUEST_SPECIFICATIONS prs

ON    
     cr.ref = prs.ref
       
left Join
    ACCOUNT_RECEIVABLES ar

ON
prs.CENTER = ar.CENTER and prs.id = ar.ID

where 
casho.generated_date = (:date) 
and casho.cashcollectionservice = (:debtagencyid)
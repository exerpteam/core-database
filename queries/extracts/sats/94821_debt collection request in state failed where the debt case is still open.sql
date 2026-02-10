-- The extract is extracted from Exerp on 2026-02-08
--  
Select

cr.ref as               paymentrequest,
CASE cr.STATE WHEN -1 THEN 'NOT_SENT' WHEN 0 THEN 'NEW' WHEN 1 THEN 'SENT' WHEN 2 THEN 'PAID' WHEN 3 THEN 'CANCELLED' WHEN 4 THEN 'RECEIVED' WHEN 6 THEN 'LEGACY' WHEN 7 THEN 'FAILED' ELSE 'Undefined' END AS "cash collection request STATE",
cr.REQ_AMOUNT as requestedamount,
cc.personcenter ||'p'|| cc.personid as personid,
cr.REQ_DELIVERY as fileid,
cr.req_date


from cashcollection_requests cr


JOIN
            cashcollectioncases cc
        ON
cc.center = cr.center
and
cc.id = cr.id  
AND cc.MISSINGPAYMENT = 1       

join persons p
on
p.center = cc.personcenter
and p.id = cc.personid

where 
cr.state = 7
and  cc.closed = 'false'
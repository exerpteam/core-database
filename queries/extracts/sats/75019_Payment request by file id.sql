SELECT
    person.CENTER || 'p' || person.id AS Personid,    
    person.fullname as "Member Name", 
--pr.req_amount as "Payment request amount",
prs.REQUESTED_AMOUNT,
prs.TOTAL_INVOICE_AMOUNT,
prs.REF,
pr.req_date as "Deduction date",
pr.REQ_DELIVERY
FROM
PAYMENT_REQUESTS pr
join
ACCOUNT_RECEIVABLES ar
ON
    pr.center = ar.center
    AND pr.id = ar.id


join
    PERSONS person
on 
ar.CUSTOMERCENTER = person.center
and
ar.CUSTOMERID = person.id

join 
PAYMENT_REQUEST_SPECIFICATIONS prs
on
pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID

where
pr.REQ_DELIVERY = (:fileid)



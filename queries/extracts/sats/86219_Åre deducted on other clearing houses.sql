-- The extract is extracted from Exerp on 2026-02-08
--  
Select distinct
p.center ||'p'|| p.id as memberid,
pr.req_date,
prs.requested_amount,
prs.open_amount,
prs.ref,
pr.creditor_id


FROM
        PAYMENT_REQUESTS pr
JOIN
        PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
                pr.INV_COLL_CENTER = prs.CENTER
                AND pr.INV_COLL_ID = prs.ID
                AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
        AR_TRANS art
        ON
                prs.CENTER = art.PAYREQ_SPEC_CENTER
                AND prs.ID = art.PAYREQ_SPEC_ID
                AND prs.SUBID = art.PAYREQ_SPEC_SUBID
JOIN
        ACCOUNT_RECEIVABLES ar
        ON
                ar.CENTER = art.CENTER
                AND ar.ID = art.ID
                AND ar.AR_TYPE = 4
JOIN
        Persons p
        ON
                ar.CUSTOMERCENTER = p.CENTER
                AND ar.CUSTOMERID = p.ID
where
p.center = 584
and req_date between :datefrom and :dateto  
and pr.clearinghouse_id not in (2215, 2412)  
and prs.paid_state = 'CLOSED' 
and prs.requested_amount > 0  
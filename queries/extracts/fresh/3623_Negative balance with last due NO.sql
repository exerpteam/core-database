SELECT
    ar.customercenter,
    ar.CUSTOMERID,
    p.firstname,
    P.lastname,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS person_STATUS,
    ar.BALANCE,
    max(pqs.due_date) as latest_due_date_in_past
FROM
     ACCOUNT_RECEIVABLES ar
JOIN persons p
    ON
        ar.customercenter = p.center
    AND ar.customerid= p.id
join payment_requests pq
    on
       ar.center = pq.center
       and ar.id = pq.id
join payment_request_specifications pqs
    on
        pq.inv_coll_center = pqs.center
    and pq.inv_coll_id = pqs.id
    and pq.inv_coll_subid = pqs.subid
WHERE
    ar.balance < 0
    and to_char(pqs.due_date,'yyyy-mm-dd')  < to_char(exerpsysdate(),'yyyy-mm-dd')
and ar.customercenter between 200 and 299
group by
    ar.customercenter,
    ar.CUSTOMERID,
    p.firstname,
    P.lastname,
    P.STATUS,
    ar.BALANCE
order by
    max(pqs.due_date)
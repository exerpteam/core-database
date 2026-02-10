-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    t.center,
    t.id,
    t.subid,
    t.trans_time,
    ar.customercenter,
    ar.customerid
FROM
    ar_trans t
JOIN
    payment_agreements pa
ON
    pa.center = t.collect_agreement_center
AND pa.id = t.collect_agreement_id
AND pa.subid = t.collect_agreement_subid

JOIN
    account_receivables ar
ON
    t.center = ar.center
AND t.id = ar.id
JOIN
    account_receivables par
ON
    pa.center = par.center
AND pa.id = par.id

WHERE
    t.collected = 0
AND(
        ar.customercenter <> par.customercenter
    OR  ar.customerid <> par.customerid);
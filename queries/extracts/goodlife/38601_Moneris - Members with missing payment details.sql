SELECT
--    longtodateTZ(pa.last_modified, 'America/Toronto')    pa_lastmodified,
    p.center ||'p'|| p.id                             AS member,
    pr.* 
--,pa.*
FROM
    PERSONs p
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
AND pr.ID = ar.ID
JOIN
    payment_agreements pa
ON
    ar.center = pa.center
AND ar.id = pa.id
AND pr.agr_subid = pa.subid
WHERE
    pr.state = 1
AND pr.clearinghouse_id = 201
AND pa.clearinghouse_ref IS NULL
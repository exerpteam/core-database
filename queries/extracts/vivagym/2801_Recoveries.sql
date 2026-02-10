-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
     SELECT
            TO_DATE(:From,'YYYY-MM-DD') AS fromDate ,
            TO_DATE(:To,'YYYY-MM-DD') AS toDate   ,
            c.id                               AS center_id,
            c.name                             AS center_name
       FROM
            centers c
    )
SELECT
    --ar.*,
    pr.center                                 AS center ,
    ar.customercenter || 'p' || ar.customerid AS person_key,
    ce.shortname  AS Center_Name  ,
    pr.req_amount AS Amount       ,
    pr.req_date   AS Fecha_emision,
    ci.id         AS File_id      ,
    ci.filename   AS File_name    ,
    --pr.state                      ,
    pr.creditor_id
FROM
    PAYMENT_REQUESTS pr
JOIN
    PARAMS par
 ON
    par.center_id = pr.center
JOIN
    vivagym.payment_request_specifications prs
 ON
    prs.center          = pr.inv_coll_center
    AND prs.id          = pr.inv_coll_id
    AND prs.subid       = pr.inv_coll_subid
    AND pr.request_type = 1
    AND pr.state NOT IN (1,2,3,4,8,12,18)
JOIN
    account_receivables ar
 ON
    ar.center = prs.center
    AND ar.id = prs.id
JOIN
        vivagym.centers ce
        ON pr.center = ce.id
LEFT JOIN
    vivagym.clearing_in ci
 ON
    ci.id = pr.xfr_delivery
WHERE
    ((
            pr.creditor_id        = '2768'
            AND ci.received_date >= par.fromDate
            AND ci.received_date <= par.toDate)
        OR (
            pr.creditor_id   = 'Adyen'
            AND pr.req_date >= par.fromDate
            AND pr.req_date <= par.toDate))
    AND EXISTS
    (
     SELECT
            1
       FROM
            PAYMENT_REQUESTS rpr
      WHERE
            prs.center           = rpr.inv_coll_center
            AND prs.id           = rpr.inv_coll_id
            AND prs.subid        = rpr.inv_coll_subid
            AND rpr.request_type = 6
            AND rpr.state IN (3,4))
UNION
SELECT
    --ar.*,
    pr.center                                 AS center ,
    ar.customercenter || 'p' || ar.customerid AS person_key,
    ce.shortname  AS Center_Name  ,
    pr.req_amount AS Amount       ,
    pr.req_date   AS Fecha_emision,
    NULL          AS File_id      ,
    NULL          AS File_name    ,
    --pr.state                      ,
    pr.creditor_id
FROM
    PAYMENT_REQUESTS pr
JOIN
    PARAMS par
 ON
    par.center_id = pr.center
JOIN
    vivagym.payment_request_specifications prs
 ON
    prs.center    = pr.inv_coll_center
    AND prs.id    = pr.inv_coll_id
    AND prs.subid = pr.inv_coll_subid
JOIN
    account_receivables ar
 ON
    ar.center = prs.center
    AND ar.id = prs.id
JOIN
        vivagym.centers ce
        ON pr.center = ce.id
LEFT JOIN
    vivagym.clearing_in ci
 ON
    ci.id = pr.xfr_delivery
WHERE
    ((
            pr.creditor_id        = '2768'
            AND ci.received_date >= par.fromDate
            AND ci.received_date <= par.toDate)
        OR (
            pr.creditor_id   = 'Adyen'
            AND pr.req_date >= par.fromDate
            AND pr.req_date <= par.toDate))
    AND pr.state             = 4
    AND pr.request_type IN (1,6)
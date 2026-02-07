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
  --  pr.center                                 AS center ,
 --    pr.id,
    ar.customercenter || 'p' || ar.customerid AS person_key,
    case 
    when p.external_id is null
    then cper.external_id
    else p.external_id
    End as "Shopper reference" ,
    ce.shortname  AS Center_Name  ,
    pr.req_amount AS Amount       ,
    pr.req_date   AS Fecha_emision,
    NULL          AS File_id      ,
    NULL          AS File_name    ,
    --pr.state                      ,
    pr.creditor_id,
    pr.xfr_date,
    pr.clearinghouse_payment_ref,
    pr.xfr_info,
    pr.rejected_reason_code
FROM
    PAYMENT_REQUESTS pr
JOIN
    PARAMS par
 ON
    par.center_id = pr.center
left JOIN
    vivagym.payment_request_specifications prs
 ON
    prs.center    = pr.inv_coll_center
    AND prs.id    = pr.inv_coll_id
    AND prs.subid = pr.inv_coll_subid
left JOIN
    account_receivables ar
 ON
    ar.center = prs.center
    AND ar.id = prs.id
left join persons p
on
ar.customercenter = p.center
and
ar.customerid = p.id

left JOIN
    persons cper
ON
    cper.center = p.transfers_current_prs_center
    AND cper.id = p.transfers_current_prs_id
    
left JOIN
        vivagym.centers ce
        ON pr.center = ce.id
LEFT JOIN
    vivagym.clearing_in ci
 ON
    ci.id = pr.xfr_delivery
WHERE
pr.creditor_id   = 'Adyen' 
and pr.req_date >= par.fromDate 
AND pr.req_date <= par.toDate
and ( pr.clearinghouse_payment_ref is not null OR pr.rejected_reason_code in ('800','905_3','803_1','803','907','REFUSED') or xfr_info in ('OK','CHARGEBACK - Other Fraud-Card ','Acquirer Error'))

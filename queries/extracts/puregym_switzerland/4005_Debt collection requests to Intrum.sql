-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ccc.personcenter||'p'||ccc.personid         AS "PersonID",
    ccr.ref                                     AS "Invoice ref",
    ccr.center||'ccol'||ccr.id||'rq'||ccr.subid AS "RequestID",
    cco.sent_date                               AS "Date sent to Intrum",
    CASE
        WHEN ccc.closed=false
        THEN extract(MONTH FROM age(CURRENT_DATE, (ccc.startdate - interval '1' day)))
        ELSE extract(MONTH FROM age(longtodateC(ccc.last_modified, ccc.center), (ccc.startdate - interval '1' day)))
    END                                           AS "Debt age" ,
    ROUND( am.amount, 2)                         AS "Settled amount",
    longtodateC(art.trans_time, art.center)::DATE AS "Settled date",
    longtodateC(art.entry_time, art.center)::DATE AS "Bank date",
    CASE
        WHEN ccr_in.subid IS NOT NULL
        THEN true
        WHEN ccr_in.subid IS NULL
        AND art.amount IS NOT NULL
        THEN false
    END                             AS "Settled over agency",
    ROUND(ccr.req_amount, 2)*-1     AS "Total debt amount",
    ROUND(art2.unsettled_amount, 2) AS "Oustanding debt amount"
FROM
    cashcollectioncases ccc
JOIN
    cashcollection_requests ccr
ON
    ccc.center=ccr.center
AND ccc.id=ccr.id
JOIN
    cashcollection_out cco
ON
    ccr.req_delivery=cco.id
JOIN
    ar_trans art2
ON
    art2.center=ccc.ar_center
AND art2.id=ccc.ar_id
AND ccr.ref=art2.info
AND art2.amount=(ccr.req_amount * -1)
LEFT JOIN
    art_match am
ON
    am.art_paid_center=art2.center
AND am.art_paid_id=art2.id
AND am.art_paid_subid=art2.subid
LEFT JOIN
    ar_trans art
ON
    am.art_paying_center=art.center
AND am.art_paying_id=art.id
AND art.subid=am.art_paying_subid
LEFT JOIN
    cashcollection_requests ccr_in
ON
    ccc.center=ccr_in.center
AND ccc.id=ccr_in.id
AND ccr_in.state=5
AND ccr_in.ref=art.info
AND art.amount=(ccr_in.req_amount * -1)
WHERE
    ccc.missingpayment=true
AND ccr.req_delivery IS NOT NULL
AND ccr.state NOT IN (5,-1,4,7)
AND ccc.cashcollectionservice=1
--AND ccc.personcenter||'p'||ccc.personid = '14p72604'
AND cco.sent_date between (:from_date)::date AND (:to_date)::date
ORDER BY
    1,
    3,4;
    
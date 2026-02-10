-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(to_char(to_date(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
                datetolongc(to_char(to_date(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 AS toDate,
                c.id
        FROM vivagym.centers c
        WHERE
                c.country = 'PT'
)
SELECT
        'FULLY/PARTIAL PAID INVOICE' AS line_type,
        ar.customercenter || 'p' || ar.customerid AS personId,
        art.ref_center || 'inv' || art.ref_id AS entityId,
        --art.center,
        --art.id,
        --art.subid,
        art.amount AS invoice_amount,
        --art.ref_center,
        --art.ref_id,
        --art.ref_subid,
        longtodateC(artm.entry_time, artm.art_paid_center) AS settlement_datetime, 
        --longtodateC(artm.cancelled_time, artm.art_paid_center) AS cancelled_datetime,
        artm.amount AS settled_amount,
        art2.ref_type AS settled_against
FROM vivagym.ar_trans art
JOIN params par ON art.center = par.id
JOIN vivagym.centers c ON art.center = c.id
JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
JOIN vivagym.art_match artm ON art.center = artm.art_paid_center AND art.id = artm.art_paid_id AND art.subid = artm.art_paid_subid
JOIN vivagym.ar_trans art2 ON art2.center = artm.art_paying_center AND art2.id = artm.art_paying_id AND art2.subid = artm.art_paying_subid
WHERE
        c.country = 'PT'
        AND art.ref_type = 'INVOICE'
        AND art.text NOT LIKE ('%Converted subscription invoice')
        AND art.amount != 0
        AND p.sex NOT IN ('C')
        AND artm.entry_time between par.fromDate AND par.toDate
UNION ALL
SELECT
        'CHARGEBACKS' AS line_type,
        ar.customercenter || 'p' || ar.customerid AS personId,
        art.ref_center || 'inv' || art.ref_id AS entityId,
        --art.center,
        --art.id,
        --art.subid,
        art.amount AS invoice_amount,
        --art.ref_center,
        --art.ref_id,
        --art.ref_subid,
        longtodateC(artm.cancelled_time, artm.art_paid_center) AS settlement_datetime, 
        artm.amount AS settled_amount,
        art2.ref_type AS settled_against
FROM vivagym.ar_trans art
JOIN params par ON art.center = par.id
JOIN vivagym.centers c ON art.center = c.id
JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
JOIN vivagym.art_match artm ON art.center = artm.art_paid_center AND art.id = artm.art_paid_id AND art.subid = artm.art_paid_subid
JOIN vivagym.ar_trans art2 ON art2.center = artm.art_paying_center AND art2.id = artm.art_paying_id AND art2.subid = artm.art_paying_subid
WHERE
        c.country = 'PT'
        AND art.ref_type = 'INVOICE'
        AND art.text NOT LIKE ('%Converted subscription invoice')
        AND art.amount != 0
        AND artm.cancelled_time IS NOT NULL
        AND p.sex NOT IN ('C')
        AND artm.cancelled_time between par.fromDate AND par.toDate
UNION ALL
-- check for cancelled ones
SELECT
        'CREDIT NOTES' AS line_type,
        ar.customercenter || 'p' || ar.customerid AS personId,
        art.ref_center || 'cred' || art.ref_id AS entityId,
        --art.center,
        --art.id,
        --art.subid,
        art.amount AS invoice_amount,
        --art.ref_center,
        --art.ref_id,
        --art.ref_subid,
        longtodateC(artm.entry_time, artm.art_paid_center) AS settlement_datetime, 
        --artm.cancelled_time,
        artm.amount AS settled_amount,
        NULL AS settled_against
FROM vivagym.ar_trans art
JOIN params par ON art.center = par.id
JOIN vivagym.centers c ON art.center = c.id
JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
JOIN vivagym.art_match artm ON art.center = artm.art_paying_center AND art.id = artm.art_paying_id AND art.subid = artm.art_paying_subid
--JOIN vivagym.ar_trans art2 ON art2.center = artm.art_paying_center AND art2.id = artm.art_paying_id AND art2.subid = artm.art_paying_subid
WHERE
        c.country = 'PT'
        AND art.ref_type = 'CREDIT_NOTE'
        --AND art.text NOT LIKE ('%Converted subscription invoice')
        AND art.amount != 0
        AND p.sex NOT IN ('C')
        AND artm.entry_time between par.fromDate AND par.toDate
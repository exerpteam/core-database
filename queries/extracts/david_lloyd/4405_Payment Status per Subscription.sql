-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/DATA-126
WITH PARAMS as Materialized
(
   select 
      id as center_id,
      CAST(:for_date AS DATE) - interval '1' day AS for_date_before,
      CAST(datetolongc(TO_CHAR(CAST(:for_date AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS  cut_timestamp
   FROM
      centers    
)
SELECT 
   s.center||'ss'||s.id as subscription_id,
   CASE WHEN COALESCE(sartm.entry_time, artm.entry_time, crt.transtime) <= params.cut_timestamp THEN 'Yes'
        WHEN spp.SPP_TYPE is null THEN 'No active subscription'
        WHEN spp.subscription_price = 0 THEN 'Yes'
        ELSE 'No' 
   END AS Paid_before_cut_date,
   COALESCE(-sart.amount,0) + COALESCE(-art.amount, crt.amount, 0) as total_amount_to_be_paid,
   COALESCE(-art.amount, crt.amount, 0) as self_amount_to_be_paid,
   COALESCE(-sart.amount,0) as sponsored_amount_to_be_paid,
   spp.from_date AS period_from_date,
   spp.to_date   AS period_to_date,   
   CASE WHEN spp.SPP_TYPE = 1 THEN 'NORMAL' 
        WHEN spp.SPP_TYPE = 2 THEN 'UNCONDITIONAL FREEZE' 
        WHEN spp.SPP_TYPE = 3 THEN 'FREE DAYS' 
        WHEN spp.SPP_TYPE = 7 THEN 'CONDITIONAL FREEZE' 
        WHEN spp.SPP_TYPE = 8 THEN 'INITIAL PERIOD' 
        WHEN spp.SPP_TYPE = 9 THEN 'PRORATA PERIOD' 
        WHEN spp.SPP_TYPE is null THEN 'No subscription period'
        ELSE 'OTHER'
   END AS subscription_period_type
FROM
    subscriptions s
JOIN
    params  
ON
    s.center = params.center_id   
LEFT JOIN
    subscriptionperiodparts spp
ON
    s.center = spp.center
    AND s.id = spp.id
    AND spp.from_date <= params.for_date_before
    AND spp.to_date >= params.for_date_before
    AND spp.spp_state = 1 -- ACTIVE
LEFT JOIN  
    SPP_INVOICELINES_LINK sil
ON
  spp.center = sil.period_center
  AND spp.id = sil.period_id
  AND spp.subid = sil.period_subid     
LEFT JOIN
  ar_trans art
ON
  art.ref_type = 'INVOICE'
  AND art.ref_center = sil.invoiceline_center
  AND art.ref_id = sil.invoiceline_id  
LEFT JOIN   
   art_match artm 
ON 
   art.center = artm.art_paid_center 
   AND art.id = artm.art_paid_id 
   AND art.subid = artm.art_paid_subid  
   AND artm.cancelled_time is null
LEFT JOIN
  invoices i
ON
  sil.invoiceline_center = i.center
  AND sil.invoiceline_id = i.id
LEFT JOIN
   invoices si
ON
   i.sponsor_invoice_center = si.center
   AND i.sponsor_invoice_id = si.id
LEFT JOIN
   ar_trans sart
ON
   sart.ref_type = 'INVOICE'
   AND sart.ref_center = si.center
   AND sart.ref_id = si.id      
LEFT JOIN   
   art_match sartm 
ON 
   sart.center = sartm.art_paid_center 
   AND sart.id = sartm.art_paid_id 
   AND sart.subid = sartm.art_paid_subid   
   AND sartm.cancelled_time is null
LEFT JOIN cashregistertransactions crt
ON
   i.paysessionid = crt.paysessionid
   AND ((i.payer_center = crt.customercenter AND i.payer_id = crt.customerid) OR crt.customercenter is NULL)   
WHERE 
  s.center || 'ss' || s.id in (:subscription_list)


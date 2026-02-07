SELECT
    p.external_id,
    pa.iban
FROM persons p
LEFT JOIN account_receivables ar
    ON ar.customercenter = p.center
   AND ar.customerid = p.id
LEFT JOIN payment_accounts pac
    ON pac.center = ar.center
   AND pac.id = ar.id
LEFT JOIN payment_agreements pa
    ON pa.center = pac.active_agr_center
   AND pa.id = pac.active_agr_id
   AND pa.subid = pac.active_agr_subid
WHERE p.external_id IN ('1013166')
  AND pa.active = TRUE;

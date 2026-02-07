-- This is the version from 2026-02-05
--  
SELECT
    pag.id                      AS paymentagreement_id,
    ca.NAME                     AS agreement_name,
    pag.CENTER                  AS agreement_center,
    conf.NAME                   AS paymentcyclename,
    pag.SUBID                   AS subid,
    p.CENTER || 'p' || p.ID     AS PERSONKEY,
    p.LASTNAME                  AS COMPANYNAME
FROM
    FW.PERSONS p
JOIN
    FW.COMPANYAGREEMENTS ca
ON
    ca.CENTER = p.CENTER
AND ca.ID= p.ID
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
    payment_accounts pa
ON
    pa.center = ar.center
AND pa.id = ar.id
JOIN
    payment_agreements pag
ON
    pag.center = pa.center
AND pag.id = pa.id
JOIN
    FW.PAYMENT_CYCLE_CONFIG conf
ON
    pag.PAYMENT_CYCLE_CONFIG_ID = conf.ID
WHERE
    p.SEX = 'C'
AND ca.STATE = '3'
AND  ar.ar_type = '4'
-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
  SELECT
    CAST(datetolong(TO_CHAR(TO_DATE(:from, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE(:to, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
    c.id                                        AS center_id,
    c.country                                   AS country
  FROM centers c
  WHERE c.id in (:scope)
),

base_art AS (
  SELECT art.*
  FROM AR_TRANS art
  JOIN params p
    ON p.center_id = art.center
  WHERE art.trans_time >= p.fromDateLong
    AND art.trans_time <  p.toDateLong
    AND art.amount > 0
    AND art.unsettled_amount <> 0
    AND art.ref_type IN ('CREDIT_NOTE')
)

SELECT distinct
  ar.customercenter || 'p' || ar.customerid                   AS pid,
  art.unsettled_amount,
  longtodate(inv.entry_time)                                   AS "invoice date",

  CASE
    WHEN p.country = 'SE' THEN
      CASE crtart.config_payment_method_id
        WHEN 7 THEN 'Benify'
        WHEN 4 THEN 'ePassi'
        WHEN 6 THEN 'Wellnet'
        ELSE 'Undefined'
      END
    WHEN p.country = 'FI' THEN
      CASE crtart.config_payment_method_id
        WHEN 2  THEN 'Smartum mobile'
        WHEN 3  THEN 'Edenred mobile'
        WHEN 5  THEN 'Epassi mobile'
        WHEN 50 THEN 'Adyen'
        ELSE 'Undefined'
      END
    WHEN p.country = 'DK' THEN
      CASE crtart.config_payment_method_id
        WHEN 1  THEN 'Pant'
        WHEN 50 THEN 'Adyen'
        ELSE 'Undefined'
      END
    WHEN p.country = 'NO' THEN
      CASE crtart.config_payment_method_id
        WHEN 1   THEN 'External Credit Card'
        WHEN 2   THEN 'Nike 3 for 2'
        WHEN 3   THEN 'Nike presentkort 2012'
        WHEN 4   THEN 'Pant'
        WHEN 50  THEN 'Adyen'
        WHEN 100 THEN 'Adyen'
        ELSE 'Undefined'
      END
    ELSE NULL
  END                                                         AS "Payment method Other",

 -- crtart.config_payment_method_id,
  payment.text                                                 AS "as text on payment",
  --payment.credit_type,
  longtodate(cn.entry_time)                                    AS "credit note date",
  art.text                                                     AS "text on creditnote"

FROM base_art art
JOIN params p
  ON p.center_id = art.center

JOIN account_receivables ar
  ON ar.center = art.center
 AND ar.id     = art.id
 AND ar.state  = 0

JOIN persons cust
  ON cust.center = ar.customercenter
 AND cust.id     = ar.customerid

JOIN credit_note_lines_mt crl
  ON crl.center = art.ref_center
 AND crl.id     = art.ref_id

JOIN credit_notes cn
  ON cn.center = crl.center
 AND cn.id     = crl.id

LEFT JOIN invoice_lines_mt invl
  ON invl.center = crl.invoiceline_center
 AND invl.id     = crl.invoiceline_id
 AND invl.subid  = crl.invoiceline_subid

LEFT JOIN invoices inv
  ON inv.center = invl.center
 AND inv.id     = invl.id

-- hvis cashregistertransactions på invoice ikke altid findes:
LEFT JOIN cashregistertransactions crt
  ON crt.artranscenter = inv.cashregister_center
 AND crt.artransid     = inv.cashregister_id
 AND crt.paysessionid  = inv.paysessionid

-- Find den AR_TRANS der repræsenterer invoice-linjen (din oprindelige join var lidt “løs”):
LEFT JOIN ar_trans inv_artrans
  ON inv_artrans.ref_center = invl.center
 AND inv_artrans.ref_id     = invl.id
-- hvis der findes subid på ref-match i jeres model, bør den med for at undgå dubletter

-- Vælg én betaling (for at undgå duplicates -> drop DISTINCT)
LEFT JOIN LATERAL (
  SELECT pay.*
  FROM art_match artm
  JOIN ar_trans pay
    ON pay.center = artm.art_paying_center
   AND pay.id     = artm.art_paying_id
   AND pay.subid  = artm.art_paying_subid
  WHERE artm.art_paid_center = inv_artrans.center
    AND artm.art_paid_id     = inv_artrans.id
    AND artm.art_paid_subid  = inv_artrans.subid
  ORDER BY pay.trans_time DESC
  LIMIT 1
) payment ON true

LEFT JOIN cashregistertransactions crtart
  ON crtart.artranscenter = payment.center
 AND crtart.artransid     = payment.id
 AND crtart.artranssubid  = payment.subid
WITH par AS MATERIALIZED (
  SELECT
    c.id AS center_id,
    datetolongC(TO_CHAR(current_date - interval '7 days', 'YYYY-MM-DD HH24:MI'), c.id) AS from_long,
    datetolongC(TO_CHAR(current_date + interval '1 day',   'YYYY-MM-DD HH24:MI'), c.id) AS to_long
  FROM fernwood.centers c
  WHERE c.id IN (:Scope)
),

-- 1) CASH REGISTER INVOICE LINES (positive)
cr_inv AS (
  SELECT
      crt.center                                         AS center_id,
      crt.customercenter                                  AS person_center,
      crt.customerid                                      AS person_id,
      CAST(longtodateC(crt.transtime, crt.center) AS timestamp) AS sale_time,
      to_char(longtodateC(crt.transtime, crt.center), 'DD/MM/YYYY') AS sale_date,
      pro.name                                            AS product_name,
      inl.quantity::numeric                               AS qty,
      inl.total_amount::numeric                           AS amount,
      'CASH REGISTER'::text                               AS payment_source
  FROM cashregistertransactions crt
  JOIN par ON par.center_id = crt.center
  JOIN invoices inv
    ON inv.paysessionid = crt.paysessionid
   AND inv.cashregister_center = crt.center
   AND inv.cashregister_id = crt.id
  JOIN invoice_lines_mt inl
    ON inv.center = inl.center AND inv.id = inl.id
  JOIN products pro
    ON pro.center = inl.productcenter AND pro.id = inl.productid
  WHERE
      crt.transtime BETWEEN par.from_long AND par.to_long
      AND crt.amount <> 0
      AND inl.total_amount <> 0
      AND pro.name ILIKE '%Foundation Donation%'
),

-- 2) CASH REGISTER CREDIT NOTE LINES (negated)
cr_cn AS (
  SELECT
      crt.center                                         AS center_id,
      crt.customercenter                                  AS person_center,
      crt.customerid                                      AS person_id,
      CAST(longtodateC(crt.transtime, crt.center) AS timestamp) AS sale_time,
      to_char(longtodateC(crt.transtime, crt.center), 'DD/MM/YYYY') AS sale_date,
      pro.name                                            AS product_name,
      cnt.quantity::numeric                               AS qty,
      (-cnt.total_amount)::numeric                        AS amount,
      'CASH REGISTER'::text                               AS payment_source
  FROM cashregistertransactions crt
  JOIN par ON par.center_id = crt.center
  JOIN credit_notes cn
    ON cn.paysessionid = crt.paysessionid
   AND cn.cashregister_center = crt.center
   AND cn.cashregister_id = crt.id
  JOIN credit_note_lines_mt cnt
    ON cnt.center = cn.center AND cnt.id = cn.id
  JOIN products pro
    ON pro.center = cnt.productcenter AND pro.id = cnt.productid
  WHERE
      crt.transtime BETWEEN par.from_long AND par.to_long
      AND crt.amount <> 0
      AND cnt.total_amount <> 0
      AND pro.name ILIKE '%Foundation Donation%'
),

-- 3) ADDON-BILLED INVOICE LINES (recurring charges / payment account)
addon_billed AS (
  SELECT
      inv.center                                         AS center_id,
      inv.payer_center                                    AS person_center,
      inv.payer_id                                        AS person_id,
      CAST(longtodateC(inv.trans_time, inv.center) AS timestamp) AS sale_time,
      to_char(longtodateC(inv.trans_time, inv.center), 'DD/MM/YYYY') AS sale_date,
      pro.name                                            AS product_name,
      inl.quantity::numeric                               AS qty,
      inl.total_amount::numeric                           AS amount,
      'ADDON'::text                                       AS payment_source
  FROM invoices inv
  JOIN par ON par.center_id = inv.center
  JOIN invoice_lines_mt inl
    ON inv.center = inl.center AND inv.id = inl.id
  JOIN products pro
    ON pro.center = inl.productcenter AND pro.id = inl.productid
  LEFT JOIN cashregistertransactions crt_link
    ON inv.paysessionid        = crt_link.paysessionid
   AND inv.cashregister_center = crt_link.center
   AND inv.cashregister_id     = crt_link.id
  WHERE
      inv.trans_time BETWEEN par.from_long AND par.to_long
      AND crt_link.id IS NULL
      AND inl.total_amount <> 0
      AND pro.name ILIKE '%Foundation Donation%'
),

all_lines AS (
  SELECT * FROM cr_inv
  UNION ALL
  SELECT * FROM cr_cn
  UNION ALL
  SELECT * FROM addon_billed
)

SELECT
    a.center_id                                   AS center,
    c.shortname                                   AS club_name,
    a.person_center || 'p' || a.person_id         AS person_key,
    p.external_id,
    p.fullname                                    AS member_name,
    a.sale_date,                                  -- DD/MM/YYYY
    a.sale_time,
    a.product_name,
    a.qty,
    a.amount,
    a.payment_source
FROM all_lines a
LEFT JOIN persons  p ON p.center = a.person_center AND p.id = a.person_id
LEFT JOIN centers  c ON c.id     = a.center_id
ORDER BY center, a.sale_time, member_name, a.product_name;

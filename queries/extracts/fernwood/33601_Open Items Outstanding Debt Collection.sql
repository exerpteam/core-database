-- Open items across AR types (as of TODAY, date-only)
WITH params AS (
  SELECT
      CURRENT_DATE AS asof_date,
      c.id         AS center_id
  FROM centers c
)
SELECT
    c.name 													  AS "Club",
	p.center || 'p' || p.id                                   AS "PersonID",
    ar.ar_type                                                AS "AR Type",
    art.ref_type                                              AS "Ref Type",
    art.text                                                  AS "Description",
    CASE art.ref_type
      WHEN 'INVOICE'       THEN art.ref_center || 'inv' || art.ref_id
      WHEN 'ACCOUNT_TRANS' THEN art.ref_center || 'acc' || art.ref_id || 'tr' || art.ref_subid
      WHEN 'CREDIT_NOTE'   THEN art.ref_center || 'cred' || art.ref_id
      ELSE art.ref_type || CHR(58) || art.ref_id::text
    END                                                       AS "Source Doc",
    longtodatec(art.entry_time, art.center)                   AS "Entry Date",
    art.due_date                                              AS "Due Date",
    -art.amount                                               AS "Total Amount",
    -art.collected_amount                                     AS "Settled Amount",
    GREATEST(-art.unsettled_amount, 0)                        AS "Open Amount",
    CASE
      WHEN art.ref_type = 'INVOICE' THEN 'Invoice'
      WHEN art.ref_type = 'ACCOUNT_TRANS' AND art.installment_plan_subindex IS NOT NULL THEN 'Installment push'
      WHEN art.ref_type = 'ACCOUNT_TRANS' THEN 'Manual invoice'
      ELSE art.ref_type
    END                                                       AS "Source"
FROM fernwood.ar_trans art
JOIN fernwood.account_receivables ar
  ON ar.center = art.center AND ar.id = art.id
JOIN fernwood.persons p
  ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN fernwood.centers c
  ON c.id = art.center
JOIN params pa
  ON pa.center_id = art.center
WHERE
      art.center IN (:Scope)
  AND COALESCE(-art.unsettled_amount, 0) > 0
  -- existed by today
  AND CAST(longtodatec(art.entry_time, art.center) AS date) <= pa.asof_date
  -- exclude today and yesterday
  AND CAST(longtodatec(art.entry_time, art.center) AS date) < pa.asof_date - INTERVAL '1 day'
  -- only include items from 01/07/2025 onwards
  AND CAST(longtodatec(art.entry_time, art.center) AS date) >= TO_DATE('01/07/2025','DD/MM/YYYY')
  -- exclude future due dates
  AND (art.due_date IS NULL OR art.due_date <= pa.asof_date)
  -- description exclusions
  AND NOT (
    art.text IN (
      'Rejection Fee',
      'Rejection Fee - Missing Payment Agreement',
      'IC - ADMIN FEES',
      'IC - CANCELLATION FEES',
      'NON RETURN FOB FEE'
    )
    OR art.text LIKE '%IC - BALANCE OF NOTICE PERIOD DUE%'
    OR art.text LIKE 'TransferToCashCollectionAccount%'
  )
ORDER BY "PersonID", "Entry Date";

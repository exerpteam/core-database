-- Open items, consolidated by Club & Month
-- Matches detailed report criteria; moves "Installment plan stopped" out of Open,
-- and duplicates Hypoxi/HDC items into a new column.
WITH params AS (
  SELECT
      CURRENT_DATE AS asof_date,
      c.id         AS center_id
  FROM centers c
),
base AS (
  SELECT
      c.name AS club,
      CAST(longtodatec(art.entry_time, art.center) AS date)   AS entry_date,
      -art.amount                                             AS total_amount,
      -art.collected_amount                                   AS settled_amount,
      GREATEST(-art.unsettled_amount, 0)                      AS open_amount_raw,
      (art.text = 'Installment plan stopped')::int            AS is_installment_stopped,
      -- Duplicate flag for Hypoxi/HDC (case-insensitive, anywhere in text)
      (art.text ILIKE '%hypoxi%' OR art.text ILIKE '%hdc%')::int AS is_hypoxi_hdc
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
    -- exclude today and yesterday (strictly before yesterday)
    AND CAST(longtodatec(art.entry_time, art.center) AS date) < pa.asof_date - INTERVAL '1 day'
    -- only include items from 01/07/2025 onwards
    AND CAST(longtodatec(art.entry_time, art.center) AS date) >= TO_DATE('01/07/2025','DD/MM/YYYY')
    -- exclude future due dates
    AND (art.due_date IS NULL OR art.due_date <= pa.asof_date)
    -- description exclusions (identical to detailed report)
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
),
agg AS (
  SELECT
      club,
      (date_trunc('month', entry_date::timestamp)
       + INTERVAL '1 month - 1 day')::date                    AS month_end,
      SUM(total_amount)                                       AS total_amount,
      SUM(settled_amount)                                     AS settled_amount,
      -- Open excludes "Installment plan stopped"
      SUM(CASE WHEN is_installment_stopped = 1
               THEN 0
               ELSE open_amount_raw
          END)                                                AS open_amount,
      -- "Installment plan stopped" captured separately
      SUM(CASE WHEN is_installment_stopped = 1
               THEN open_amount_raw
               ELSE 0
          END)                                                AS installment_plan_stopped,
      -- Hypoxi/HDC duplicates open amount whenever matched (even if also Installment Stopped)
      SUM(CASE WHEN is_hypoxi_hdc = 1
               THEN open_amount_raw
               ELSE 0
          END)                                                AS hypoxi_hdc_open
  FROM base
  GROUP BY club, month_end
)
SELECT
    club                                         AS "Club",
    TO_CHAR(month_end, 'DD/MM/YYYY')             AS "Entry Month",
    total_amount                                 AS "Total Amount",
    settled_amount                               AS "Settled Amount",
    open_amount                                  AS "Open Amount",
    installment_plan_stopped                     AS "Installment plan stopped",
    hypoxi_hdc_open                              AS "Hypoxi/HDC"
FROM agg
ORDER BY "Club", "Entry Month";

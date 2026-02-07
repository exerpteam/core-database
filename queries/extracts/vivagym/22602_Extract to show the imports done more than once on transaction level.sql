WITH params AS
(
    SELECT
        TO_DATE(:from,'YYYY-MM-DD') AS fromDate,
        TO_DATE(:to,'YYYY-MM-DD')   AS toDate,
        c.id   AS center_id,
        c.name AS center_name
    FROM centers c
    WHERE c.id IN (:scope)
),
base AS (
    SELECT
        pr.center AS center,
        ce.shortname AS Center_Name,
        ar.customercenter || 'p' || ar.customerid AS person_key,
        pr.req_amount AS Amount,
        pr.req_date  AS Fecha_emision,
        ci.received_date AS fecha_importacion,
        ci.generated_date as generated_date,  
        ci.id        AS File_id,
        ci.filename  AS File_name,
        pr.creditor_id,
        ci.ref       AS ref,
        ci.clearinghouse,
        CASE
            WHEN pr.state IN (1,12)
                THEN 'Transaction NOT sent to bank'
            ELSE 'Transaction sent to bank '
        END AS Sent_status,
        -- Tæl hvor mange rækker der findes pr. (person_key, ref)
        COUNT(*) OVER (
            PARTITION BY ar.customercenter, ar.customerid, ci.ref
        ) AS ref_count_per_person
    FROM PAYMENT_REQUESTS pr
    JOIN clearing_in ci
      ON ci.id = pr.xfr_delivery
    JOIN params par
      ON par.center_id = pr.center
    JOIN ACCOUNT_RECEIVABLES ar
      ON ar.center = pr.center
     AND ar.id     = pr.id
    JOIN vivagym.centers ce
      ON pr.center = ce.id
    WHERE ci.received_date >= par.fromDate
      AND ci.received_date <= par.toDate
      -- evt. ekstra filtre kan blive her:
      -- AND ci.clearinghouse = '2801'
      -- AND pr.creditor_id LIKE '2768'
)
SELECT
    center,
    Center_Name,
    person_key,
    Amount,
    Fecha_emision,
    fecha_importacion,
    generated_date,
    File_id,
    File_name,
    creditor_id,
    ref,
    clearinghouse,
    Sent_status
FROM base
WHERE ref_count_per_person >= 2
ORDER BY person_key, ref, fecha_importacion
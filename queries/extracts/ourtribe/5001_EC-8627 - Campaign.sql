-- The extract is extracted from Exerp on 2026-02-08
--  
WITH date_scope AS (
    SELECT 
        (:start_date)::DATE AS start_date,
        (:end_date)::DATE AS end_date
),
invoices_precomputed AS (
    SELECT id,
           center,
           trans_time,
           TO_TIMESTAMP(trans_time / 1000) AS trans_date
    FROM invoices, date_scope
    WHERE TO_TIMESTAMP(trans_time / 1000) BETWEEN date_scope.start_date AND date_scope.end_date
)
SELECT distinct
       per.center||'p'||per.id as Member_id,
       per.fullname AS person_name,
       CASE 
        WHEN per.status = 1 THEN 'Active' 
        ELSE 'Inactive' 
        END AS active_status,
       inv.trans_date AS purchase_date,
       CASE
           WHEN LOWER(sub.sub_comment) LIKE LOWER('%Halloween SoMe konkurrence - få 2 måneder til dig og din makker for 0 kr%')
           THEN 'Halloween SoMe konkurrence - få 2 måneder til dig og din makker for 0 kr'
           WHEN LOWER(sub.sub_comment) LIKE LOWER('%Alle zoners (fra CFC forside konkurrence - 2 måneders træning)%')
           THEN 'Alle zoners (fra CFC forside konkurrence - 2 måneders træning)'
           WHEN LOWER(sub.sub_comment) LIKE LOWER('%Alle zoner (Fra Træn til 1. oktober for 10 kr)%')
           THEN 'Alle zoner (Fra Træn til 1. oktober for 10 kr)'
           ELSE LEFT(sub.sub_comment, 50) || '...'
       END AS campaign
FROM persons per
JOIN invoice_lines_mt invl
  ON per.id = invl.person_id
 AND per.center = invl.center
JOIN subscriptions sub
  ON invl.center = sub.invoiceline_center
 AND invl.id = sub.invoiceline_id
JOIN invoices_precomputed inv
  ON invl.center = inv.center
 AND invl.id = inv.id
WHERE (
        LOWER(sub.sub_comment) LIKE LOWER('%Halloween SoMe konkurrence - få 2 måneder til dig og din makker for 0 kr%')
        OR LOWER(sub.sub_comment) LIKE LOWER('%Alle zoners (fra CFC forside konkurrence - 2 måneders træning)%')
        OR LOWER(sub.sub_comment) LIKE LOWER('%Alle zoner (Fra Træn til 1. oktober for 10 kr)%')
      )
ORDER BY inv.trans_date;
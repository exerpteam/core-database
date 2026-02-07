-- This is the version from 2026-02-05
--  
WITH filtered_trans AS (
    SELECT *
    FROM ar_trans
    WHERE trans_time >= :time_from
      AND trans_time <  :time_to + 86400000
      AND text LIKE 'Opkrævning for ''Personlig trænin%'
)
SELECT
    ft.*,
    per.center || 'p' || per.id AS memberid
FROM filtered_trans ft
LEFT JOIN account_receivables ar
       ON ft.center = ar.center
      AND ft.id     = ar.id
JOIN persons per
     ON per.center = ar.customercenter
    AND per.id     = ar.customerid;

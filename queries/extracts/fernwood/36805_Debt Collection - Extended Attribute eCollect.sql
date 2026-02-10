-- The extract is extracted from Exerp on 2026-02-08
--  
-- eCollect members: all AR transactions from Payment, External Debt, Installment
WITH params AS (
  SELECT
      -- From: 6 days ago (so 7 days incl. today)
      datetolongC(TO_CHAR(CAST(CURRENT_DATE - INTERVAL '120 day' AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
      c.id AS center_id,
      -- To: end of today (center-local)
      CAST((
          datetolongC(TO_CHAR((CAST(CURRENT_DATE AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1
      ) AS BIGINT) AS ToDate
  FROM centers c
)
SELECT
    longtodateC(art.entry_time, art.center)                 AS "Date",
    CASE ar.ar_type
      WHEN 4 THEN 'PAYMENT'
      WHEN 5 THEN 'EXTERNAL_DEBT'
      WHEN 6 THEN 'INSTALLMENT'
      ELSE 'OTHER'
    END                                                     AS "Account Type",
    art.text                                                AS "Text",
    art.ref_type                                            AS "Ref Type",
    art.due_date                                            AS "Due Date",
    art.amount                                              AS "Amount",
    c.shortname                                             AS "Center",
    art.info                                                AS "Info",
    ar.customercenter || 'p' || ar.customerid               AS "Person ID",
    p.fullname                                              AS "Full Name"
FROM persons p

JOIN person_ext_attrs pea
  ON pea.personcenter = p.center
 AND pea.personid     = p.id
 AND pea.name         = 'eCollect'
 AND pea.txtvalue ILIKE 'yes%'
JOIN account_receivables ar
  ON ar.customercenter = p.center
 AND ar.customerid     = p.id
JOIN ar_trans art
  ON art.center = ar.center
 AND art.id     = ar.id
JOIN centers c
  ON c.id = art.center
JOIN params pms
  ON pms.center_id = art.center
WHERE
    ar.ar_type IN (4,5,6)
    AND art.entry_time BETWEEN pms.FromDate AND pms.ToDate
    AND art.center IN (:Scope)
    AND NOT (
      art.text ILIKE 'Installment plan stopped%' OR
      art.text ILIKE 'IC - CANCELLATION FEES%'   OR
      art.text ILIKE 'IC - ADMIN FEES%'          OR
      art.text ILIKE '2ND INSTALMENT NOTICE PERIOD%'
    )
ORDER BY
    "Person ID", "Date" DESC;

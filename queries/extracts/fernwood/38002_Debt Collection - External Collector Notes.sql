-- The extract is extracted from Exerp on 2026-02-08
--  
WITH j AS (
  SELECT
      je.person_center,
      je.person_id,
      je.name AS note_heading,
      CASE
        WHEN is_utf8_encoded(je.big_text) = 'true' THEN convert_from(je.big_text, 'UTF-8')::text
        ELSE je.big_text::text
      END AS note_details,
      je.creatorcenter AS author_center,
      je.creatorid     AS author_id,
      je.creation_time
  FROM journalentries je
  WHERE
      je.person_center IN (:Scope)
      AND (longtodateC(je.creation_time, je.person_center))::date
          BETWEEN (CURRENT_DATE - INTERVAL '7 day')::date
              AND CURRENT_DATE::date
      -- more tolerant name match:
      AND btrim(je.name) ILIKE 'external collector note%'
)
SELECT
    j.person_center || 'p' || j.person_id AS "Person ID",
    TO_CHAR((longtodateC(j.creation_time, j.person_center))::date, 'DD/MM/YYYY') AS "Note Date",
    c.name         AS "Club",
    p.fullname     AS "Member Name",
    j.note_heading AS "Note Heading",
    COALESCE(j.note_details, '') AS "Note Details",
    pay_ar.balance  AS "Payment Account Balance",
    inst_ar.balance AS "Installment Account Balance",
    ext_ar.balance  AS "External Debt Account Balance",
    CASE WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes' ELSE 'No' END AS "eCollect",
    COALESCE(staff_from_emp.fullname, staff_direct.fullname, '') AS "Staff Name"
FROM j
JOIN persons p
  ON p.center = j.person_center AND p.id = j.person_id
JOIN centers c
  ON c.id = p.center
LEFT JOIN account_receivables pay_ar
  ON pay_ar.customercenter = j.person_center
 AND pay_ar.customerid     = j.person_id
 AND pay_ar.ar_type        = 4
LEFT JOIN account_receivables inst_ar
  ON inst_ar.customercenter = j.person_center
 AND inst_ar.customerid     = j.person_id
 AND inst_ar.ar_type        = 6
LEFT JOIN account_receivables ext_ar
  ON ext_ar.customercenter = j.person_center
 AND ext_ar.customerid     = j.person_id
 AND ext_ar.ar_type        = 5
LEFT JOIN person_ext_attrs pea
  ON pea.personcenter = j.person_center
 AND pea.personid     = j.person_id
 AND pea.name         = 'eCollect'
LEFT JOIN employees e
  ON e.center = j.author_center
 AND e.id     = j.author_id
LEFT JOIN persons staff_from_emp
  ON staff_from_emp.center = e.personcenter
 AND staff_from_emp.id     = e.personid
LEFT JOIN persons staff_direct
  ON staff_direct.center = j.author_center
 AND staff_direct.id     = j.author_id
ORDER BY "Person ID", "Note Date" DESC;

-- The extract is extracted from Exerp on 2026-02-08
--  
WITH j AS (
  SELECT
      je.person_center,
      je.person_id,
      je.name AS note_heading,
      CASE
        WHEN is_utf8_encoded(je.big_text) = 'true'
          THEN CAST(convert_from(je.big_text, 'UTF-8') AS TEXT)
        ELSE CAST(je.big_text AS TEXT)
      END AS note_details,
      je.creatorcenter AS author_center,
      je.creatorid     AS author_id,
      je.creation_time
  FROM journalentries je
  WHERE
      je.person_center IN (:Scope)
      -- Date range (inclusive): choose these in the report parameters
      AND CAST(longtodateC(je.creation_time, je.person_center) AS date)
          BETWEEN CAST(:FromDate AS date) AND CAST(:ToDate AS date)
      -- include ALL journal notes
),
src AS (
  SELECT
      j.*,
      e.personcenter  AS emp_person_center,
      e.personid      AS emp_person_id
  FROM j
  LEFT JOIN employees e
    ON e.center = j.author_center
   AND e.id     = j.author_id
),
auth AS (
  SELECT
      s.*,
      COALESCE(s.emp_person_center, s.author_center) AS resolved_author_center,
      COALESCE(s.emp_person_id,     s.author_id)     AS resolved_author_id
  FROM src s
)
SELECT
    a.person_center || 'p' || a.person_id                                        AS "Person ID",
    TO_CHAR(CAST(longtodateC(a.creation_time, a.person_center) AS date), 'DD/MM/YYYY') AS "Note Date",
    c.name                                                                        AS "Club",
    p.fullname                                                                    AS "Member Name",
    a.note_heading                                                                AS "Note Heading",
    COALESCE(a.note_details, '')                                                  AS "Note Details",
    pay_ar.balance                                                                AS "Payment Account Balance",       -- ar_type = 4
    inst_ar.balance                                                               AS "Installment Account Balance",   -- ar_type = 6
    ext_ar.balance                                                                AS "External Debt Account Balance", -- ar_type = 5
    CASE WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes' ELSE 'No' END                  AS "eCollect",
    a.resolved_author_center || 'p' || a.resolved_author_id                       AS "Author Person ID",
    COALESCE(staff_from_emp.fullname, staff_direct.fullname, '')                  AS "Staff Name"
FROM auth a
JOIN persons p
  ON p.center = a.person_center AND p.id = a.person_id
JOIN centers c
  ON c.id = p.center
LEFT JOIN account_receivables pay_ar
  ON pay_ar.customercenter = a.person_center
 AND pay_ar.customerid     = a.person_id
 AND pay_ar.ar_type        = 4
LEFT JOIN account_receivables inst_ar
  ON inst_ar.customercenter = a.person_center
 AND inst_ar.customerid     = a.person_id
 AND inst_ar.ar_type        = 6
LEFT JOIN account_receivables ext_ar
  ON ext_ar.customercenter = a.person_center
 AND ext_ar.customerid     = a.person_id
 AND ext_ar.ar_type        = 5
LEFT JOIN person_ext_attrs pea
  ON pea.personcenter = a.person_center
 AND pea.personid     = a.person_id
 AND pea.name         = 'eCollect'
LEFT JOIN persons staff_from_emp
  ON staff_from_emp.center = a.emp_person_center
 AND staff_from_emp.id     = a.emp_person_id
LEFT JOIN persons staff_direct
  ON staff_direct.center = a.author_center
 AND staff_direct.id     = a.author_id
WHERE (a.resolved_author_center || 'p' || a.resolved_author_id) IN (
  '100p51002','314p60673','100p61801','319p10002','307p66809','100p64820','100p15401','327p37728','100p207'
)
ORDER BY "Person ID", "Note Date" DESC;

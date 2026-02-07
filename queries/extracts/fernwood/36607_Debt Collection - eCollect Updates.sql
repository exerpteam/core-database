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
      AND je.person_center NOT IN (321, 320, 305, 309, 702, 601, 311, 303, 312, 314)
      AND CAST(longtodateC(je.creation_time, je.person_center) AS date)
          BETWEEN CAST(CURRENT_DATE - INTERVAL '30 day' AS date)
              AND CAST(CURRENT_DATE AS date)
      AND regexp_replace(lower(coalesce(je.name,'')), '\s+', '', 'g') LIKE '%ecollect%'
      AND lower(regexp_replace(coalesce(je.name,''), '\s+', ' ', 'g')) NOT IN (
          lower('Collections - Debt Referred to eCollect'),
          lower('Collections - MINOR - Debt Referred to eCollect (in name of parent/guardian)')
      )
)

SELECT
    j.person_center || 'p' || j.person_id                      AS "Person ID",
    TO_CHAR(CAST(longtodateC(j.creation_time, j.person_center) AS date), 'DD/MM/YYYY') AS "Note Date",
    c.name                                                     AS "Club",
    p.fullname                                                 AS "Member Name",
    j.note_heading                                             AS "Note Heading",
    COALESCE(j.note_details, '')                               AS "Note Details",
    pay_ar.balance                                             AS "Payment Account Balance",
    inst_ar.balance                                            AS "Installment Account Balance",
    ext_ar.balance                                             AS "External Debt Account Balance",
    CASE WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes' ELSE 'No' END AS "eCollect",
    COALESCE(staff_from_emp.fullname, staff_direct.fullname, '') AS "Staff Name"
FROM j
JOIN fernwood.persons p
  ON p.center = j.person_center AND p.id = j.person_id
JOIN fernwood.centers c
  ON c.id = p.center
LEFT JOIN fernwood.account_receivables pay_ar
  ON pay_ar.customercenter = j.person_center
 AND pay_ar.customerid     = j.person_id
 AND pay_ar.ar_type        = 4
LEFT JOIN fernwood.account_receivables inst_ar
  ON inst_ar.customercenter = j.person_center
 AND inst_ar.customerid     = j.person_id
 AND inst_ar.ar_type        = 6
LEFT JOIN fernwood.account_receivables ext_ar
  ON ext_ar.customercenter = j.person_center
 AND ext_ar.customerid     = j.person_id
 AND ext_ar.ar_type        = 5
LEFT JOIN fernwood.person_ext_attrs pea
  ON pea.personcenter = j.person_center
 AND pea.personid     = j.person_id
 AND pea.name         = 'eCollect'
LEFT JOIN fernwood.employees e
  ON e.center = j.author_center
 AND e.id     = j.author_id
LEFT JOIN fernwood.persons staff_from_emp
  ON staff_from_emp.center = e.personcenter
 AND staff_from_emp.id     = e.personid
LEFT JOIN fernwood.persons staff_direct
  ON staff_direct.center = j.author_center
 AND staff_direct.id     = j.author_id
ORDER BY
    CAST(longtodateC(j.creation_time, j.person_center) AS date) DESC,
    j.person_center,
    j.person_id;

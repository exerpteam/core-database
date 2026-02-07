-- PARAMETERS:
-- :Scope      -> list of centers (keep your usual scope picker)
-- :PersonID   -> e.g. '100p12345' (center || 'p' || id)

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
      AND (je.person_center || 'p' || je.person_id) = :PersonID
      -- Exclude specific headings (exact match)
      AND je.name NOT IN (
        'Apply step: Run workflow transitions',
        'Apply step: Add To Journal',
        'Apply: ''Change person attribute''',
        'Apply step: Create tasks',
        'Apply step: Update debt collection cases',
        'Apply step: Stop subscriptions',
        'Apply step: Create account receivable transaction - extended info',
		'StartedDebtCollectionProcedure',
		'Started missing agreement procedure',
        'Apply step: Cancel Active Payment Agreements'
      )
),
src AS (
  SELECT
      j.*,
      e.personcenter  AS emp_person_center,
      e.personid      AS emp_person_id
  FROM j
  LEFT JOIN fernwood.employees e
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
    TO_CHAR(CAST(longtodateC(a.creation_time, a.person_center) AS date), 'DD/MM/YYYY') AS "Note Date",
    a.note_heading                                                                      AS "Note Heading",
    COALESCE(a.note_details, '')                                                        AS "Note Details",
    COALESCE(staff_from_emp.fullname, staff_direct.fullname, 'Unknown')                 AS "Author Name"
FROM auth a
LEFT JOIN fernwood.persons staff_from_emp
  ON staff_from_emp.center = a.emp_person_center
 AND staff_from_emp.id     = a.emp_person_id
LEFT JOIN fernwood.persons staff_direct
  ON staff_direct.center = a.author_center
 AND staff_direct.id     = a.author_id
ORDER BY "Note Date" DESC;

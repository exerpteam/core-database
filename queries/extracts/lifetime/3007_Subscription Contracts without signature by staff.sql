-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    je.creatorcenter||'emp'||je.creatorid AS staffid,
    emp1.fullname,
    COUNT(JE.*) AS subcount
FROM
    lifetime.journalentries je
JOIN
    lifetime.persons p
ON
    p.center = je.person_center
AND p.id = je.person_id
LEFT JOIN
    lifetime.journalentry_signatures jes
ON
    je.id = jes.journalentry_id

JOIN
    employees emp
ON
    je.creatorcenter = emp.center
AND je.creatorid = emp.id

join persons emp1 on emp.personcenter = emp1.center and emp.personid = emp1.id

WHERE
    je.jetype = 36 -- Aggregated customer contract
AND jes.signature_center IS NULL
AND je.signable = true
GROUP BY
    staffid,
    emp1.fullname
ORDER BY
    subcount,
    staffid
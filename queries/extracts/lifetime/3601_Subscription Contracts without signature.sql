-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.fullname as "Member Name",
		p.center || 'p' || p.id AS PersonId,
        p.external_id,
emp1.fullname as TrainerName,
longtodateC(creation_time,person_center) as ENTRY_TIME
FROM
        lifetime.journalentries je
JOIN
        lifetime.persons p
        ON
                p.center = je.person_center
                AND p.id = je.person_id
JOIN
    employees emp
ON
    je.creatorcenter = emp.center
AND je.creatorid = emp.id

join persons emp1 on emp.personcenter = emp1.center and emp.personid = emp1.id
LEFT JOIN
        lifetime.journalentry_signatures jes
        ON
                je.id = jes.journalentry_id
WHERE
        je.jetype = 36 -- Aggregated customer contract
        AND jes.signature_center IS NULL
		AND je.signable = true
AND je.person_center IN ($$Scope$$)
AND
	je.creation_time >= dateToLongC(to_char(to_date(:Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),je.person_center) 
AND 
	je.creation_time <= dateToLongC(to_char(to_date(:End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),je.person_center) 
order by creation_time DESC
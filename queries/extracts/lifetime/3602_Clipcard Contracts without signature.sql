-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.fullname as "Member Name",
		p.center || 'p' || p.id AS PersonId,
        p.external_id,
emp1.fullname as TrainerName,
        pd.name,
        pd.globalid,
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
LEFT JOIN
        lifetime.clipcards c 
                ON je.ref_center = c.center
                AND je.ref_id = c.id
                AND je.ref_subid = c.subid
LEFT JOIN
        lifetime.clipcardtypes ct
                ON ct.center = c.center AND ct.id = c.id
JOIN 
        lifetime.products pd ON pd.center = ct.center AND pd.id = ct.id
WHERE
        je.jetype = 34 -- Clipcard contract
        AND jes.signature_center IS NULL
        AND je.signable = true
		AND je.person_center IN ($$Scope$$)
AND
	je.creation_time >= dateToLongC(to_char(to_date(:Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),je.person_center) 
AND 
	je.creation_time <= dateToLongC(to_char(to_date(:End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),je.person_center) 
order by creation_time DESC
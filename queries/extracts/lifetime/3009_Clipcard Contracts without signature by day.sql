-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
TO_CHAR(longtodateC(creation_time,person_center),'YYYY-MM-DD') as ENTRY_TIME,
    COUNT(JE.*) AS clipcount
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
LEFT JOIN
    lifetime.clipcards c
ON
    je.ref_center = c.center
AND je.ref_id = c.id
AND je.ref_subid = c.subid
LEFT JOIN
    lifetime.clipcardtypes ct
ON
    ct.center = c.center
AND ct.id = c.id
JOIN
    lifetime.products pd
ON
    pd.center = ct.center
AND pd.id = ct.id
JOIN
    persons emp
ON
    je.creatorcenter = emp.center
AND je.creatorid = emp.id
WHERE
    je.jetype = 34 -- Clipcard contract
AND jes.signature_center IS NULL
AND je.signable = true
        GROUP BY ENTRY_TIME
order by ENTRY_time ASC
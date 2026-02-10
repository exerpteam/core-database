-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        --p.fullname as "Member Name",p.center || 'p' || p.id AS PersonId,        p.external_id,
TO_CHAR(longtodateC(creation_time,person_center),'YYYY-MM-DD') as ENTRY_TIME, COUNT(JE.*) as subcount
FROM
        lifetime.journalentries je

LEFT JOIN
        lifetime.journalentry_signatures jes
        ON
                je.id = jes.journalentry_id
WHERE
        je.jetype = 36 -- Aggregated customer contract
        AND jes.signature_center IS NULL
		AND je.signable = true
		GROUP BY ENTRY_TIME
order by ENTRY_time ASC
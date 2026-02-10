-- The extract is extracted from Exerp on 2026-02-08
-- Shows the count of contracts not signed for clipcards & subscriptions

         SELECT
             --TO_CHAR(longtodateC(creation_time,person_center),'YYYY-MM-DD') as ENTRY_TIME,
              t1.subcount as subscriptions_not_signed,t2.clipcount as clipcards_not_signed, t1.subcount+t2.clipcount as total from(select COUNT(JE.*) as subcount
         FROM
             lifetime.journalentries je
         LEFT JOIN
             lifetime.journalentry_signatures jes
         ON
             je.id = jes.journalentry_id
         WHERE
             je.jetype = 36 -- Aggregated customer contract
         AND jes.signature_center IS NULL
         AND je.signable = true)t1,
         --GROUP BY ENTRY_TIME ORDER BY ENTRY_time ASC
         (SELECT
    COUNT(JE.*) AS clipcount
FROM
    lifetime.journalentries je

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

WHERE
    je.jetype = 34 -- Clipcard contract
AND jes.signature_center IS NULL
AND je.signable = true
       )t2
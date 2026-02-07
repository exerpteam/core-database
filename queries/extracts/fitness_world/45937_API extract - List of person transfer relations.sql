-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-3912
SELECT distinct
    p2.center || 'p' || p2.id AS "Member ID",
    CASE
        WHEN (p2.TRANSFERS_CURRENT_PRS_CENTER = p2.center
            AND p2.TRANSFERS_CURRENT_PRS_ID = p2.id)
        THEN '(active/current)'
        ELSE '(relation)'
    END "Relation Type"
FROM
    PERSONS p
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
AND pea.PERSONID = p.id
AND pea.NAME = '_eClub_Email'
JOIN
    persons p2
ON
    p2.TRANSFERS_CURRENT_PRS_CENTER =p.TRANSFERS_CURRENT_PRS_CENTER
AND p2.TRANSFERS_CURRENT_PRS_ID = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    (
        $$personExternalId$$ = p.EXTERNAL_ID
    OR  $$personExternalId$$ = 'defaultExternalId')
AND (
    SUBSTR($$personKey$$,0,position('p' IN $$personKey$$)) = p.TRANSFERS_CURRENT_PRS_CENTER::VARCHAR
    AND SUBSTR($$personKey$$,position('p' IN $$personKey$$)+1) = p.TRANSFERS_CURRENT_PRS_ID::VARCHAR
    OR  $$personKey$$ = '0p0')
AND (
        $$email$$ = pea.TXTVALUE
    OR  $$email$$ = 'default@email.com')

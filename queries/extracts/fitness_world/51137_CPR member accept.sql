-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-7038
SELECT 
    SUM(CASE WHEN gdpr.TXTVALUE = 'true' AND cre.TXTVALUE < '2018-05-25' THEN 1 END) AS "Accept_Before_GDPR",
    SUM(CASE WHEN gdpr.TXTVALUE = 'false' AND cre.TXTVALUE < '2018-05-25' THEN 1 END) AS "Decline_Before_GDPR",
    SUM(CASE WHEN gdpr.TXTVALUE = 'true' AND cre.TXTVALUE >= '2018-05-25' THEN 1 END) AS "Accept_After_GDPR",
    SUM(CASE WHEN gdpr.TXTVALUE = 'false' AND cre.TXTVALUE >= '2018-05-25' THEN 1 END) AS "Decline_After_GDPR"
FROM 
    PERSONS p
JOIN
    PERSON_EXT_ATTRS gdpr
ON
    p.CENTER = gdpr.PERSONCENTER
    AND p.ID = gdpr.PERSONID
    AND gdpr.name IN ('UGSSNGDPRACCEPT','SSNGDPRACCEPT')
JOIN
    PERSON_EXT_ATTRS cre
ON
    p.CENTER = cre.PERSONCENTER
    AND p.ID = cre.PERSONID
    AND cre.name = 'CREATION_DATE'
WHERE
    p.center in (:Centers)
    AND p.STATUS NOT IN (4,5,7,8)
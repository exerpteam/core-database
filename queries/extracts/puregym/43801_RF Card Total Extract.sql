-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3448
SELECT
    c.SHORTNAME "Gym Name", count(*) "RF Card Count"
FROM
    ENTITYIDENTIFIERS ei
JOIN
    CENTERS c
ON
    c.id = ei.REF_CENTER
WHERE
    ei.IDMETHOD = 4
AND ei.ENTITYSTATUS = 1
AND ei.START_TIME >= :From_Date
GROUP BY c.SHORTNAME

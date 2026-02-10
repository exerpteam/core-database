-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3448
SELECT
    c.SHORTNAME "Gym Name", ei.REF_CENTER||'p'||ei.REF_ID AS "Member ID", ei.IDENTITY AS "Card No", TO_CHAR(longtodate(ei.START_TIME),'YYYY-MM-DD') AS "Start Date"
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
AND ei.REF_CENTER in (:Scope)
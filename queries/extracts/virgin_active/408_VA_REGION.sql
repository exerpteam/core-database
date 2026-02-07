
SELECT
    a.ID "RegionID",
    '"' || replace(a.NAME,'"','""') || '"' "RegionName"
FROM
    AREAS a
WHERE
    a.BLOCKED = 0
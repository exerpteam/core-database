-- The extract is extracted from Exerp on 2026-02-08
-- For testing amendments to extract queries
SELECT
    cen.*                                                                 
FROM
    CENTERS cen
WHERE cen.ID In (:scope)
ORDER BY
    cen.ID
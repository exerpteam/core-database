SELECT
    cen.*                                                                 
FROM
    CENTERS cen
WHERE cen.ID In (:scope)
ORDER BY
    cen.ID
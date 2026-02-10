-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.NAME       AS CENTER,
    re.NAME        AS Gate_Name,
    re.EXTERNAL_ID AS Gate_ID,
    re.COMENT      AS COMENT,
    re.STATE       AS Status
FROM
    PUREGYM.BOOKING_RESOURCES re
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = re.CENTER
WHERE
    re.CENTER IN (:scope)
ORDER BY
    cen.NAME
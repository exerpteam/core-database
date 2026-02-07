-- This is the version from 2026-02-05
--  
SELECT
    c.external_id AS site_id
    ,true  AS exerp_is_migrated
    ,c.id         AS exerp_center
    ,NULL         AS code
    ,co.name      AS country
    , c.country   AS country_iso_code
    , lic.start_Date <=CURRENT_DATE
AND
    (
        lic.stop_Date > CURRENT_DATE
    OR  lic.stop_date IS NULL)
             AS is_active
    , c.name AS NAME
    , NULL   AS email_suffix
FROM
    centers c
JOIN
    countries co
ON
    co.id = c.country
LEFT JOIN
    licenses lic
ON
    lic.center_id = c.id
AND lic.feature = 'clubLead'
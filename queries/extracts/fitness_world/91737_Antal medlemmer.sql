-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    BI_PERSONS biview
where Persons.center in (:scope)
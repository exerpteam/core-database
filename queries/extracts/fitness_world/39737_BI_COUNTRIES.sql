-- This is the version from 2026-02-05
--  
SELECT
    ID      "COUNTRY_ID",
    NAME                      AS "NAME",
    COUNTRIES.DEFAULTTIMEZONE AS "TIMEZONE"
FROM
    COUNTRIES

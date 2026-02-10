-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ID      "COUNTRY_ID",
    NAME                      AS "NAME",
    COUNTRIES.DEFAULTTIMEZONE AS "TIMEZONE"
FROM
    COUNTRIES

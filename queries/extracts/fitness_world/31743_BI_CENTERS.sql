-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    CAST ( c.ID AS VARCHAR(255))       "CENTER_ID",
    c.EXTERNAL_ID AS                   "EXTERNAL_ID",
    c.NAME        AS                   "NAME",
    c.SHORTNAME   AS                   "SHORTNAME",
    TO_CHAR(STARTUPDATE, 'YYYY-MM-DD') "STARTUP_DATE",
    c.COUNTRY                          "COUNTRY_CODE",
    c.ZIPCODE                          "POSTAL_CODE",
    c.ADDRESS1                AS                      "ADDRESS1",
    c.ADDRESS1                AS                      "ADDRESS2",
    c.ADDRESS1                AS                      "ADDRESS3",
    c.PHONE_NUMBER            AS                      "PHONE_NUMBER",
    c.CITY                    AS                      "CITY",
    REPLACE(TO_CHAR(c.LATITUDE,'FM990D000000'),'.',',') AS "LATITUDE",
    REPLACE(TO_CHAR(c.LONGITUDE,'FM990D000000'),'.',',') AS "LONGITUDE",
    Migrations.MIGRATION_DATE AS                      "MIGRATION_DATE",
    c.TIME_ZONE               AS                      "TIME_ZONE",
    p.EXTERNAL_ID             AS                      "MANAGER_PERSON_ID",
    z.COUNTY                  AS                      "COUNTY",
    z.PROVINCE                AS                      "STATE"
FROM
    CENTERS c
LEFT JOIN
    PERSONS p
ON
    p.CENTER = c.MANAGER_CENTER
    AND p.ID = c.MANAGER_ID
LEFT JOIN
    (
        SELECT
            ces.NEWENTITYCENTER,
            MAX(ces.LASTUPDATED) AS MIGRATION_DATE
        FROM
            CONVERTER_ENTITY_STATE ces
        GROUP BY
            ces.NEWENTITYCENTER) Migrations
ON
    Migrations.NEWENTITYCENTER = c.id
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = c.COUNTRY
    AND z.ZIPCODE = c.ZIPCODE
    AND z.CITY = c.CITY
-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    CAST ( c.ID AS VARCHAR(255))       "CENTERS.CENTER_ID",
    c.EXTERNAL_ID AS                   "CENTERS.EXTERNAL_ID",
    c.NAME        AS                   "CENTERS.NAME",
    c.SHORTNAME   AS                   "CENTERS.SHORTNAME",
    TO_CHAR(STARTUPDATE, 'YYYY-MM-DD') "CENTERS.STARTUP_DATE",
    REPLACE(c.PHONE_NUMBER, '+61','0') AS "CENTERS.PHONE",
    c.EMAIL                         AS "CENTERS.EMAIL",
    CASE
        WHEN LENGTH(c.EMAIL) > 0
        THEN SPLIT_PART(c.EMAIL,'@',1) || '@email.' || SPLIT_PART(c.EMAIL,'@',2)
        ELSE ''
    END        AS                     "CENTERS.EMAIL_SUBDOMAIN",
    c.COUNTRY  AS                     "CENTERS.COUNTRY_CODE",
    c.ZIPCODE  AS                     "CENTERS.POSTAL_CODE",
    c.ADDRESS1 AS                     "CENTERS.ADDRESS1",
    c.ADDRESS2 AS                     "CENTERS.ADDRESS2",
    c.ADDRESS3 AS                     "CENTERS.ADDRESS3",
    c.CITY     AS                     "CENTERS.CITY",
    CAST(c.LATITUDE AS VARCHAR(255))  "CENTERS.LATITUDE",
    CAST(c.LONGITUDE AS VARCHAR(255)) "CENTERS.LONGITUDE",
    c.TIME_ZONE    AS                    "CENTERS.TIME_ZONE",
    z.COUNTY       AS                    "CENTERS.COUNTY",
    z.PROVINCE     AS                    "CENTERS.STATE",
    cea1.txt_value AS                    "CENTERS.FRANCHISE_ID",
    cea2.txt_value AS                    "CENTERS.BRAND"
FROM
    CENTERS c
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = c.COUNTRY
AND z.ZIPCODE = c.ZIPCODE
AND z.CITY = c.CITY
LEFT JOIN
    center_ext_attrs cea1
ON
    cea1.center_id = c.ID
AND cea1.name = 'FranchiseId'
LEFT JOIN
    center_ext_attrs cea2
ON
    cea2.center_id = c.ID
AND cea2.name = 'Brand'
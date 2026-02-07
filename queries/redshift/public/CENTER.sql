SELECT DISTINCT
    c.ID                                                                     "ID",
    c.EXTERNAL_ID AS                                                         "EXTERNAL_ID",
    c.NAME        AS                                                         "NAME",
    c.SHORTNAME   AS                                                         "SHORTNAME",
    STARTUPDATE                                                              "STARTUP_DATE",
    c.COUNTRY                                                                "COUNTRY_CODE",
    c.ZIPCODE                                                                "POSTAL_CODE",
    c.ADDRESS1     AS                                                        "ADDRESS1",
    c.ADDRESS2     AS                                                        "ADDRESS2",
    c.ADDRESS3     AS                                                        "ADDRESS3",
    c.PHONE_NUMBER AS                                                        "PHONE_NUMBER",
    c.EMAIL        AS                                                        "EMAIL",   
    c.CITY         AS                                                        "CITY",
    c.LATITUDE                                                               "LATITUDE",
    c.LONGITUDE                                                              "LONGITUDE",
    to_date(TO_CHAR(Migrations.MIGRATION_DATE,'yyyy-MM-dd'),'yyyy-MM-dd') AS "MIGRATION_DATE",
    c.TIME_ZONE                                                           AS "TIME_ZONE",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END        AS "MANAGER_PERSON_ID",
    z.COUNTY   AS "COUNTY",
    z.PROVINCE AS "STATE",
    CASE
        WHEN c.center_type = 1 THEN 'GLOBAL_HEAD_OFFICE'
        WHEN c.center_type = 2 THEN 'NATIONAL_HEAD_OFFICE'
        WHEN c.center_type = 3 THEN 'REGIONAL_HEAD_OFFICE'
        WHEN c.center_type = 4 THEN 'CENTER'
        ELSE 'UNDEFINED'      
        END               AS     "CENTER_TYPE"
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
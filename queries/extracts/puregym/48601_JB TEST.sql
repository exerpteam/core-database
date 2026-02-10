-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    to_char(cen.ID)                       AS "GYMID",
    cen.SHORTNAME                         AS "SHORTNAME",
    cen.NAME                              AS "NAME",
    TO_CHAR(cen.STARTUPDATE,'yyyy-MM-dd') AS "STARTUPDATE",
    cen.PHONE_NUMBER                      AS "PHONENUMBER",
    cen.EMAIL                             AS "EMAIL",
    cen.ORG_CODE                          AS "ORGCODE",
    cen.ADDRESS1                          AS "ADDRESS1",
    cen.ADDRESS2                          AS "ADDRESS2",
    cen.ADDRESS3                          AS "ADDRESS3",
    cen.COUNTRY                           AS "COUNTRY",
    cen.ZIPCODE                           AS "ZIPCODE",
    cen.LATITUDE                          AS "LATITUDE",
    cen.LONGITUDE                         AS "LONGITUDE",
    cen.EXTERNAL_ID                       AS "EXTERNALID",
    cen.CITY                              AS "CITY",
    cen.WEB_NAME                          AS "WEBNAME",
    gm_cp.FULLNAME                        AS "GM",
    agm_cp.FULLNAME                       AS "AGM",
    region.NAME                           AS "REGIONAL",    
    to_char(gm_cp.EXTERNAL_ID)            AS "MANAGERID",                                                                               
    CASE 
	WHEN cen.STARTUPDATE > TRUNC(SYSDATE) 
	THEN 1 
	ELSE 0 END                            AS "PREJOIN",
	(CASE WHEN MIN(prod.PRICE) IS NOT NULL
        THEN MIN(prod.PRICE)
        ELSE single.PRICE
    END) AS "LOWEST_PRICE_POINT"
FROM
    PUREGYM.CENTERS cen
LEFT JOIN
    PUREGYM.PERSONS gm
ON
    gm.CENTER = cen.MANAGER_CENTER
    AND gm.ID = cen.MANAGER_ID
LEFT JOIN
    PUREGYM.PERSONS gm_cp
ON
    gm.CURRENT_PERSON_CENTER = gm_cp.CENTER
    AND gm.CURRENT_PERSON_ID = gm_cp.ID
LEFT JOIN
    PUREGYM.PERSONS agm
ON
    agm.CENTER = cen.ASST_MANAGER_CENTER
    AND agm.ID = cen.ASST_MANAGER_ID
LEFT JOIN
    PUREGYM.PERSONS agm_cp
ON
    agm.CURRENT_PERSON_CENTER = agm_cp.CENTER
    AND agm.CURRENT_PERSON_ID = agm_cp.ID
JOIN
    PUREGYM.AREA_CENTERS ar1
ON
    ar1.CENTER = cen.ID
LEFT JOIN
    PUREGYM.AREAS region
ON
    region.ID = ar1.AREA
LEFT JOIN 
    products prod
ON
    prod.CENTER = cen.ID
    AND  prod.primary_product_group_id = 5602
	AND  prod.blocked = 0 
LEFT JOIN 
    products single
ON
    single.CENTER = cen.ID
    AND single.NAME = 'CORE'
    AND  single.blocked = 0
OR
    single.CENTER = cen.ID
    AND single.NAME = 'Direct Debit Prejoin + Joining Fee New'
    AND single.blocked = 0
WHERE
    cen.id in ($$scope$$)
    AND region.PARENT = 61
GROUP BY
    cen.ID,
    cen.SHORTNAME,
    cen.NAME,
    cen.STARTUPDATE,
    cen.PHONE_NUMBER,
    cen.EMAIL,
    cen.ORG_CODE,
    cen.ADDRESS1,
    cen.ADDRESS2,
    cen.ADDRESS3,
    cen.COUNTRY,
    cen.ZIPCODE,
    cen.LATITUDE,
    cen.LONGITUDE,
    cen.EXTERNAL_ID,
    cen.CITY,
    cen.WEB_NAME,
    gm_cp.FULLNAME,
    agm_cp.FULLNAME,
    region.NAME,    
    to_char(gm_cp.EXTERNAL_ID),
    single.price
ORDER BY cen.ID
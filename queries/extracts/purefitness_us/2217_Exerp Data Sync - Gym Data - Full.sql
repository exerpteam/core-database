-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.ID                       AS "GYMID",
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
--    region.NAME                           AS "REGIONAL",    
    
    gm_cp.EXTERNAL_ID            AS "MANAGERID",                                                                               
    CASE 
	WHEN cen.STARTUPDATE > getcentertime(cen.id)::date
	THEN 1 
	ELSE 0 END                            AS "PREJOIN",
	(CASE WHEN MIN(prod.PRICE) IS NOT NULL
        THEN MIN(prod.PRICE)
        ELSE single.PRICE
    END) AS "LOWEST_PRICE_POINT" ,

  ( CASE
  WHEN single.globalid='SINGLE_ACCESS_SUBSCRIPTION' 
  THEN single.price
   ELSE NULL
   END ) as "LOWEST_CORE_PRICE_POINT",
   cen.time_zone   AS "TIMEZONE",
   MIN(t2.min_prod) FILTER (WHERE t2.external_id = 'OffPeak') AS "LOWEST_OFFPEAK_PRICE_POINT",
   MIN(t2.min_prod) FILTER (WHERE t2.external_id = 'MULTI ACCESS') AS "LOWEST_MULTIACCESS_PRICE_POINT",
   MIN(t2.min_prod) FILTER (WHERE t2.external_id = 'PREMIUM') AS "LOWEST_PREMIUM_PRICE_POINT",
   MIN(t2.min_prod) FILTER (WHERE t2.external_id = 'NATIONAL MULTI ACCESS') AS "LOWEST_NATIONAL_PRICE_POINT",
   MIN(t2.min_prod) FILTER (WHERE t2.external_id = 'NATIONAL-PREMIUM') AS "LOWEST_NATIONALPREMIUM_PRICE_POINT"
FROM
    CENTERS cen
LEFT JOIN
    PERSONS gm
ON
    gm.CENTER = cen.MANAGER_CENTER
    AND gm.ID = cen.MANAGER_ID
LEFT JOIN
    PERSONS gm_cp
ON
    gm.CURRENT_PERSON_CENTER = gm_cp.CENTER
    AND gm.CURRENT_PERSON_ID = gm_cp.ID
LEFT JOIN
    PERSONS agm
ON
    agm.CENTER = cen.ASST_MANAGER_CENTER
    AND agm.ID = cen.ASST_MANAGER_ID
LEFT JOIN
    PERSONS agm_cp
ON
    agm.CURRENT_PERSON_CENTER = agm_cp.CENTER
    AND agm.CURRENT_PERSON_ID = agm_cp.ID
--JOIN
--    AREA_CENTERS ar1
--ON
--    ar1.CENTER = cen.ID
--LEFT JOIN
--    AREAS region
--ON
--    region.ID = ar1.AREA
LEFT JOIN 
    products prod
ON
    prod.CENTER = cen.ID
    AND  prod.primary_product_group_id = 203 -- Privs - Monthly - Off Peak
	AND  prod.blocked = 0 
LEFT JOIN 
    products single
ON
    single.CENTER = cen.ID
    AND single.NAME = 'CORE'
    AND  single.blocked = 0
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.external_id,
            ROUND(MIN(pr.price),2) AS min_prod
        FROM
            products pr
        WHERE
            pr.external_id in ('OffPeak', 'MULTI ACCESS', 'PREMIUM','NATIONAL MULTI ACCESS','NATIONAL-PREMIUM')
        AND pr.blocked = false
        GROUP BY
            pr.center,
            pr.external_id ) t2
ON
    t2.center = cen.id    
WHERE
    cen.id in ($$scope$$)
--    AND region.PARENT in (7,8,9,10) -- Regions 1 - 4
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
--    region.NAME,    
    gm_cp.EXTERNAL_ID,
    single.price , 
single.globalid
ORDER BY cen.ID
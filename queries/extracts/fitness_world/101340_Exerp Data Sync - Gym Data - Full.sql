-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  DISTINCT
    cen.ID                                AS "GYMID",
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
    gm_cp.EXTERNAL_ID                     AS "MANAGERID",
    CASE
        WHEN cen.STARTUPDATE > date_trunc('day', CURRENT_TIMESTAMP)
        THEN 1
        ELSE 0
    END AS "PREJOIN",
    /*(
        CASE
            WHEN MIN(prod.PRICE) IS NOT NULL
            THEN MIN(prod.PRICE)
            ELSE single.PRICE
        END)*/
        MIN(t2.min_prod) AS "LOWEST_PRICE_POINT" ,
    /*(
        CASE
            WHEN single.globalid LIKE 'CORE_MONTHLY' 
            THEN single.price
            ELSE NULL
        END ) */ MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%CORE%') AS "LOWEST_CORE_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%CLASSES%') AS "LOWEST_CORE_CLASSES_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%OFFPEAK%') AS "LOWEST_OFFPEAK_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%PLUS%') AS "LOWEST_MULTIACCESS_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%PLUS%') AS "LOWEST_PREMIUM_PRICE_POINT",
       --LOWEST_PREMIUM.min_price AS "LOWEST_PREMIUM_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%UNLIMITED%') AS "LOWEST_NATIONAL_PRICE_POINT",
       MIN(t2.min_prod) FILTER (WHERE t2.external_id LIKE '%UNLIMITED%') AS "LOWEST_NATIONALPREMIUM_PRICE_POINT",
       null as "LOWEST_CORE_ANNUAL_PRICE_POINT",
       null as "LOWEST_PREMIUM_ANNUAL_PRICE_POINT",
       cen.time_zone   AS "TIMEZONE"       
FROM
    CENTERS cen
LEFT JOIN PERSONS gm ON gm.CENTER = cen.MANAGER_CENTER
AND
gm.ID = cen.MANAGER_ID LEFT JOIN PERSONS gm_cp ON gm.CURRENT_PERSON_CENTER = gm_cp.CENTER
AND
gm.CURRENT_PERSON_ID = gm_cp.ID LEFT JOIN PERSONS agm ON agm.CENTER = cen.ASST_MANAGER_CENTER
AND
agm.ID = cen.ASST_MANAGER_ID
LEFT JOIN
    PERSONS agm_cp
ON
    agm.CURRENT_PERSON_CENTER = agm_cp.CENTER
AND agm.CURRENT_PERSON_ID = agm_cp.ID
JOIN
    AREA_CENTERS ar1
ON
    ar1.CENTER = cen.ID
LEFT JOIN
    AREAS region
ON
    region.ID = ar1.AREA
LEFT JOIN
    products prod
ON
    prod.CENTER = cen.ID
AND prod.external_id LIKE '%OFFPEAK%' --off peak
AND prod.blocked = 0
LEFT JOIN
    products single
ON
    single.CENTER = cen.ID
--AND single.NAME like '%Core%'
AND single.external_id LIKE '%CORE%'
AND single.blocked = 0
/*LEFT JOIN 
 products lowest_annual_core
ON
    lowest_annual_core.CENTER = cen.ID
AND (lowest_annual_core.external_id = 'LOCAL12' OR lowest_annual_core.name = 'Core 12')
AND lowest_annual_core.blocked = 0
LEFT JOIN 
 products lowest_annual_premium
ON
    lowest_annual_premium.CENTER = cen.ID
AND (lowest_annual_premium.external_id = 'PREMIUM12' OR lowest_annual_premium.name = 'Premium 12')
AND lowest_annual_core.blocked = 0 */
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.external_id,
            ROUND(MIN(pr.price),2) AS min_prod
        FROM
            products pr
        WHERE
            (pr.external_id LIKE '%OFFPEAK%' OR  pr.external_id LIKE '%CLASSES%' OR pr.external_id LIKE '%PLUS%' OR pr.external_id LIKE'%UNLIMITED%'
            OR pr.external_id LIKE'%CORE%')
        AND pr.blocked = false
        GROUP BY
            pr.center,
            pr.external_id ) t2
ON
    t2.center = cen.id
/*LEFT JOIN
(
        select pr.center as center, min(pr.price) min_price
        from 
           product_and_product_group_link ppl
        join products pr
           on pr.center = ppl.product_center
           and pr.id = ppl.product_id
        where 
          pr.external_id LIKE '%PLUS%' 
          --and ppl.product_group_id = 4205 -- product_group Extra Subscription
           and pr.blocked is false
        GROUP BY pr.center   
) AS LOWEST_PREMIUM 
ON 
    LOWEST_PREMIUM.center =  cen.id  */ 
WHERE
 cen.id IN (:scope) AND
 --region.id = 2
 region.root_area IN (1)
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
    gm_cp.EXTERNAL_ID,
    single.price ,
    single.globalid,
    single.external_id
   -- LOWEST_PREMIUM.min_price,
   -- lowest_annual_core.price,
   -- lowest_annual_premium.price
ORDER BY
    cen.ID
    
    
    
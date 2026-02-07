SELECT
     cen.ID,
     cen.SHORTNAME,
     cen.NAME,
     TO_CHAR(cen.STARTUPDATE,'yyyy-MM-dd') AS STARTUPDATE,
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
zsr.txt_value AS ZSR, 
provid.txt_value AS PROVID, 
centerweb.txt_value AS CenterAvailableOnWebFrom, 
date.txt_value AS date, 
     gm.FULLNAME                                                                                      AS GM,
     agm.FULLNAME                                                                                     AS AGM,
     region.NAME                                                                                      AS Regional,
     CASE cen.MANAGER_CENTER||'p'||cen.MANAGER_ID WHEN 'p' THEN NULL ELSE cen.MANAGER_CENTER||'p'||cen.MANAGER_ID END AS "ManagerID",
     CASE  WHEN jf.center IS NULL THEN 'false' ELSE 'true' END                                                            AS "Prejoin"
 FROM
     CENTERS cen
 LEFT JOIN
     PERSONS gm
 ON
     gm.CENTER = cen.MANAGER_CENTER
     AND gm.ID = cen.MANAGER_ID
 LEFT JOIN
     PERSONS agm
 ON
     agm.CENTER = cen.ASST_MANAGER_CENTER
     AND agm.ID = cen.ASST_MANAGER_ID
 JOIN
     AREA_CENTERS ar1
 ON
     ar1.CENTER = cen.ID
 LEFT JOIN
     AREAS region
 ON
     region.ID = ar1.AREA
LEFT JOIN
     (
         SELECT DISTINCT
             txt_value, 
				name, 
				center_id
         FROM
             center_ext_attrs cea
         WHERE
             cea.name IN ('ZSR')) zsr
     ON cen.id = zsr.center_id

LEFT JOIN
     (
         SELECT DISTINCT
             txt_value, 
				name, 
				center_id
         FROM
             center_ext_attrs cea
         WHERE
             cea.name IN ('PROVID')) provid
     ON cen.id = provid.center_id

LEFT JOIN
     (
         SELECT DISTINCT
             txt_value, 
				name, 
				center_id
         FROM
             center_ext_attrs cea
         WHERE
             cea.name IN ('Date')) date
     ON cen.id = date.center_id

LEFT JOIN
     (
         SELECT DISTINCT
             txt_value, 
				name, 
				center_id
         FROM
             center_ext_attrs cea
         WHERE
             cea.name IN ('CenterAvailableOnWebFrom')) centerweb
     ON cen.id = centerweb.center_id

 LEFT JOIN
     (
         SELECT DISTINCT
             center
         FROM
             PRODUCTS pr
         WHERE
             pr.GLOBALID IN ('PREJOIN_JF_PG')
             AND pr.BLOCKED = 0) jf
 ON
     jf.center = cen.id
WHERE
	 region.PARENT = 2
